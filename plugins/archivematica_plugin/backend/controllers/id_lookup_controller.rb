class ArchivesSpaceService < Sinatra::Base

  class IDLookup

    def find_by_ids(model, id_maps)
      filters = {}

      id_maps.each do |column, ids|
        if !Array(ids).empty?
          filters[column] = Array(ids)

        end
      end

      return [] if filters.empty?

      model.filter(filters).select(:id).map {|record|
        {'ref' => record.uri}
      }
    end

  end


  Endpoint.get('/repositories/:repo_id/find_by_id/archival_objects')
    .description("Find Archival Objects by ref_id or component_id")
    .params(["repo_id", :repo_id],
            ["ref_id", [String], "A set of record Ref IDs", :optional => true],
            ["component_id", [String], "A set of record component IDs", :optional => true],
            ["resolve", :resolve])
    .permissions([:view_repository])
    .returns([200, "JSON array of refs"]) \
  do
    refs = IDLookup.new.find_by_ids(ArchivalObject, :ref_id => params[:ref_id], :component_id => params[:component_id])
    json_response(resolve_references({'archival_objects' => refs}, params[:resolve]))
  end


  Endpoint.get('/repositories/:repo_id/find_by_id/digital_object_components')
    .description("Find Digital Object Components by component_id")
    .params(["repo_id", :repo_id],
            ["component_id", [String], "A set of record component IDs", :optional => true],
            ["resolve", :resolve])
    .permissions([:view_repository])
    .returns([200, "JSON array of refs"]) \
  do
    refs = IDLookup.new.find_by_ids(DigitalObjectComponent, :component_id => params[:component_id])
    json_response(resolve_references({'digital_object_components' => refs}, params[:resolve]))
  end

end
