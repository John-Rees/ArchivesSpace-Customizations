ExportHelpers.module_eval do;
  def generate_mods(id)
    obj = resolve_references(DigitalObject.to_jsonmodel(id), ['repository::agent_representation', 'linked_agents', 'subjects', 'tree', 'linked_instances'])
    mods = ASpaceExport.model(:mods).from_digital_object(JSONModel(:digital_object).new(obj))
    ASpaceExport::serialize(mods)
  end
end

class MODSModel < ASpaceExport::ExportModel
  model_for :mods

  include JSONModel

  attr_accessor :digital_object_id
  attr_accessor :dates
  attr_accessor :resource
  attr_accessor :component
  
  @archival_object_map = {
    :digital_object_id => :digital_object_id=,
    :title => :title=,
    :language => :language_term=,
    :extents => :handle_extent,
    :subjects => :handle_subjects,
    :linked_agents => :handle_agents,
    :notes => :handle_notes,
    :dates => :handle_dates,
    :linked_instances => :handle_instances,
  }
  
  @name_type_map = {
  'agent_person' => 'personal',
  'agent_family' => 'family',
  'agent_corporate_entity' => 'corporate',
  'agent_software' => nil
  }
  
  def initialize
    @digital_object_id = []
    @extents = []
    @notes = []
    @subjects = []
    @names = []
    @parts = []
    @dates = []
    @component = []
    @resource = []
  end
  
  def handle_dates(dates)
    dates.each do |date|
      self.dates << {
        'label' => date['label'],
        'expression' => date['expression'],
        'begin' => date['begin'],
        'end' => date['end'],
        'type' => date['date_type'],
        'certainty' => date['certainty'],
        'era' => date['era'],
        'calendar' => date['calendar'],
      } 
    end
  end

  def handle_instances(linked_instances)
    linked_instances.each do |link|
      component = link['_resolved']
      resourceLink = component['resource']['ref']
      self.component << {
        'ref_id' => component['ref_id'],
        'title' => component['display_string']
      }
      resource = Resource.to_jsonmodel(JSONModel(:resource).id_for(resourceLink))
      self.resource << {
        'title' => resource['title'],
        'identifier' => resource['ead_id']
      }
    end
  end

end
