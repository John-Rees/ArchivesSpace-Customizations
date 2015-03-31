# plugins/local/frontend/models/search_result_data.rb
# redefines facets, which you can see at:
# https://github.com/archivesspace/archivesspace/blob/master/frontend/app/models/search_result_data.rb#L215-L257
 
 
require Rails.root.join('app/models/search_result_data')
 
class SearchResultData
 
# this changes what facets are requested for Resource searches. Display order follows the order in the array. 
 def self.RESOURCE_FACETS
   [ "level", "primary_type", "subjects", "publish"]
 end

 def self.DIGITAL_OBJECT_FACETS
   ["digital_object_type", "primary_type", "subjects", "publish", "level"]
 end
 
end
