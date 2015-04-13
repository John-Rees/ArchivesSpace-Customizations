#HA: commented out requires. This may affect functionality

#require_relative 'converter'

class EADConverter < Converter

  #require 'securerandom'
  #require_relative 'lib/xml_sax'
  #include ASpaceImport::XML::SAX

    %w(accessrestrict accessrestrict/legalstatus \
       accruals acqinfo altformavail appraisal arrangement \
       bioghist custodhist dimensions \
       fileplan odd otherfindaid originalsloc phystech \
       prefercite processinfo relatedmaterial scopecontent \
       separatedmaterial userestrict ).each do |note|
      with note do |node|
        content = inner_xml.tap {|xml|
          xml.sub!(/<head>.*?<\/head>/m, '')
          # xml.sub!(/<list [^>]*>.*?<\/list>/m, '')
          # xml.sub!(/<chronlist [^>]*>.*<\/chronlist>/m, '')
        }

        make :note_multipart, {
          :type => node.name,
          :persistent_id => att('id'),
		      :publish => att('audience') != 'internal',
          :subnotes => {
		    'jsonmodel_type' => 'note_text',
			'content' => format_content( content )
          }
        } do |note|
          set ancestor(:resource, :archival_object), :notes, note
        end
      end      
    end


end