# Replaces export helpers so that TSV files are streamed and don't time out
# If pull request #267 is merged into AS core this code block will no longer be necessary
ExportHelpers.module_eval do;

  def tsv_response(tsv_streamer)
    [status, {"Content-Type" => "text/tab-separated-values"}, tsv_streamer]
  end

  # This method will return an object that Rack will know to stream
  def generate_labels(id)
    obj = resolve_references(Resource.to_jsonmodel(id), ['tree', 'repository'])
    labels = ASpaceExport.model(:labels).from_resource(JSONModel(:resource).new(obj))

    Enumerator.new do |y|
      y << labels.headers.join("\t") + "\r"

      labels.stream_rows(y)
    end

  end
end


class LabelModel < ASpaceExport::ExportModel
  model_for :labels

  include JSONModel
  include ASpaceExport::LazyChildEnumerations

  @ao = Class.new do
    include ASpaceExport::LazyChildEnumerations

    def initialize(tree, repo_id)
      @repo_id = repo_id
      # @tree = tree
      @children = tree ? tree['children'] : []
      @child_class = self.class
      @json = nil
      RequestContext.open(:repo_id => repo_id) do
        rec = URIResolver.resolve_references(ArchivalObject.to_jsonmodel(tree['id']), ['subjects', 'linked_agents', 'digital_object', 'parent'], {'ASPACE_REENTRANT' => false})
        @json = JSONModel::JSONModel(:archival_object).new(rec)
      end
    end

    def method_missing(meth)
      if @json.respond_to?(meth)
        @json.send(meth)
      else
        nil
      end
    end

    def children
      return nil unless @tree['children']
      @tree['children'].map { |subtree| self.class.new(subtree) }
    end
  end

  def initialize(obj)
    @json = obj
    @children = @json.tree['_resolved']['children']
    @child_class = self.class.instance_variable_get(:@ao)
    repo_ref = obj.repository['ref']
    #repo_ref
    @repo_id = JSONModel::JSONModel(:repository).id_for(repo_ref)

  end


  def stream_rows(y)
    each_row(self, y)
  end


  def each_row(obj, y)
    obj.children_indexes.each do |i|
      child = obj.get_child(i)

      generate_rows(child).each do |row|
        fullrow = [self.title, self.identifier, row['parents'], row['container']]
        y << fullrow.join("\t") + "\r"
        end

      each_row(child, y)

    end

  end



  def generate_rows(node)
    rows = []

    #get parent components
    if node.parent
      parents = []
      parents = get_parents(node.parent['_resolved'], parents)
    end

    #get containers
    node.instances.each do |i|
      c = i['container']
      next unless c
      if c['type_1'] && c['indicator_1']
        container = "#{c['type_1'].capitalize} #{c['indicator_1']}"
        crow = {
            'container' => container,
            'parents' => parents
          }
        end
      rows << crow
    end

    rows
  end

  def headers
      %w(Resource\ Title  Resource\ Identifier Parents Container)
  end

  def get_parents(node, parents)

    if node['level']!='file' && node['level']!='item'
        title = [node['level'], node['component_id'], node['display_string']].compact.join(' ').titlecase
    else
        title = node['display_string']
    end
    parents << title

    if node['parent']

      obj = nil

      RequestContext.open(:repo_id => @repo_id) do
        obj = ArchivalObject.to_jsonmodel(JSONModel(:archival_object).id_for(node['parent']['ref']))
      end

      get_parents(obj, parents) if obj

    end

    parents = parents.reverse.join(' > ')

  end

end
