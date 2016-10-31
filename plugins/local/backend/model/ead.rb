require 'nokogiri'
require 'securerandom'
class EADSerializer < ASpaceExport::Serializer
  serializer_for :ead

  def prefix_id(id)
    if id.nil? or id.empty? or id == 'null'
      ""
    else
      id
    end
  end
end
