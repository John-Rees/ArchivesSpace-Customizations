  ExportHelpers.module_eval do;
    def generate_mets(id)
      obj = resolve_references(DigitalObject.to_jsonmodel(id), ['repository::agent_representation', 'linked_agents', 'subjects', 'tree', 'linked_instances'])
      mets = ASpaceExport.model(:mets).from_digital_object(JSONModel(:digital_object).new(obj))
      ASpaceExport::serialize(mets)
    end
  end

class METSSerializer < ASpaceExport::Serializer 
  serializer_for :mets

  private

  def mets(data, xml)
    xml.mets('xmlns' => 'http://www.loc.gov/METS/', 
             'xmlns:mods' => 'http://www.loc.gov/mods/v3', 
             'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
             'xmlns:xsi' => "http://www.w3.org/2001/XMLSchema-instance",
             'xsi:schemaLocation' => "http://www.loc.gov/standards/mets/mets.xsd"){
      # xml.metsHdr(:CREATEDATE => Time.now) {
      #   xml.agent(:ROLE => data.header_agent_role, :TYPE => data.header_agent_type) {
      #     xml.name data.header_agent_name
      #     data.header_agent_notes.each do |note|
      #       xml.note note
      #     end
      #   }        
      # }

      xml.dmdSec(:ID => data.dmd_id) {
        xml.mdWrap(:MDTYPE => 'MODS') {
          xml.xmlData {
            ASpaceExport::Serializer.with_namespace('mods', xml) do
              mods_serializer = ASpaceExport.serializer(:mods).new
              mods_serializer.serialize_mods(data.mods_model, xml)
            end
          }
        }          
      }

      data.children.each do |component_data|
        serialize_child_dmd(component_data, xml)
      end

      xml.amdSec {
        data.file_versions.each do |file|
          serialize_techmd(file, xml)
        end
        data.rights_statements.each do |rights|
          serialize_rightsmd(rights, xml)
        end
      }

      xml.fileSec { 
        data.with_file_groups do |file_group|
          xml.fileGrp(:USE => file_group.use) {
            file_group.with_files do |file|
              xml.file(:ID => file.id, :GROUPID => file.group_id, :AMDID => file.id) {
                xml.FLocat("xlink:href" => file.uri)
              }
            end
          }
        end
      }

      xml.structMap(:TYPE => 'logical') {
        serialize_logical_div(data.root_logical_div, xml)
      }

      xml.structMap(:TYPE => 'physical') {
        serialize_physical_div(data.root_physical_div, xml)
      }
    }
  end

  def serialize_techmd(file, xml)
    xml.techMD(:ID => file['identifier']) {
      xml.mdWrap(:MDTYPE => 'PREMIS:OBJECT') {
        xml.xmlData {
          xml.object('xmlns' => 'info:lc/xmlns/premis-v2',
            'xsi:type' => 'file',
            'xsi:schemaLocation' => 'info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/v2/premis-v2-2.xsd',
            'version' => '2.2') {
            xml.objectIdentifier {
              xml.objectIdentifierType 'ArchivesSpace identifier'
              xml.objectIdentifierValue file['identifier']
            }
            xml.objectCharacteristics {
              xml.fixity {
                xml.messageDigestAlgorithm file['checksum_method']
                xml.messageDigest file['checksum']
              }
              xml.size file['file_size_bytes']
              xml.format {
                xml.formatDesignation {
                  xml.formatName file['file_format_name']
                  xml.formatVersion file['file_format_version']
                }
              }
            }
          }
        }
      }
    }
  end

  def serialize_rightsmd(rights, xml)
    xml.rightsMD {
      xml.mdWrap(:MDTYPE => 'PREMIS:RIGHTS') {
        xml.xmlData {
          xml.rightsStatement('xmlns' => 'info:lc/xmlns/premis-v2',
            'xsi:type' => 'file',
            'xsi:schemaLocation' => 'info:lc/xmlns/premis-v2 http://www.loc.gov/standards/premis/v2/premis-v2-2.xsd',
            'version' => '2.2') {
            xml.rightsStatementIdentifier {
              xml.rightsStatementIdentifierType 'UUID'
              xml.rightsStatementIdentifierValue rights['identifier']
            }
            case rights['rights_type']
            when 'intellectual_property'
              xml.rightsBasis 'Copyright'
              xml.copyrightInformation {
                xml.copyrightStatus rights['ip_status']
                xml.copyrightJurisdiction rights['jurisdiction']
                xml.copyrightNote rights['type_note']
                xml.copyrightApplicableDates {
                  xml.endDate rights['ip_expiration_date']
                }
              }
            when 'license'
              xml.rightsBasis 'License'
              xml.licenseInformation {
                xml.licenseTerms rights['license_identifier_terms']
                xml.licenseNote rights['type_note']
              }
            when 'institutional_policy'
              xml.rightsBasis 'Other'
              xml.otherRightsInformation 
            when 'statute'
              xml.rightsBasis 'Statute'
              xml.statuteInformation {
                xml.statuteCitation rights['statute_citation']
                xml.statuteJurisdiction rights['jurisdiction']
                xml.statuteNote rights['type_note']
              }
            end
            xml.rightsGranted {
              xml.act rights['restrictions'] + rights['permissions']
              xml.restriction 
                if(rights['restrictions']) 
                  'disallow' 
                else 
                  'allow'
                end
              xml.termOfGrant {
                xml.startDate rights['restriction_start_date']
                xml.endDate rights['restriction_end_date']
              }
              xml.rightsGrantedNote rights['granted_note']
            }
          }
        }
      }
    }
  end

end
