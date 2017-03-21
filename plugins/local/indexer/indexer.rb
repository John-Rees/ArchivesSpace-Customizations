class CommonIndexer
  add_indexer_initialize_hook do |indexer|
    indexer.add_document_prepare_hook do |doc, record|
      doc['fullrecord'] = CommonIndexer.extract_string_values(record)                                                                                                                
      %w(finding_aid_subtitle finding_aid_author).each do |field|                                                                                                                    
        if record['record'].has_key?(field)                                                                                                                                          
          doc['fullrecord'] << "#{record['record'][field]} "                                                                                                                         
        end                                                                                                                                                                          
      end                                                                                                                                                                            
                                                                                                                                                                                     
      if record['record'].has_key?('names')                                                                                                                                          
        doc['fullrecord'] << record['record']['names'].map {|name|                                                                                                                   
          CommonIndexer.extract_string_values(name)                                                                                                                                  
        }.join(" ")                                                                                                                                                                  
      end 
    end
  end
end