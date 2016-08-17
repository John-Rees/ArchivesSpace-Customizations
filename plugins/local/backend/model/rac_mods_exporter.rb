class MODSSerializer < ASpaceExport::Serializer
  serializer_for :mods

  include JSONModel

  def serialize_mods_inner(mods, xml)

    xml.titleInfo {
      xml.title mods.title
    }
    
    xml.typeOfResource mods.type_of_resource

    xml.originInfo {
      mods.dates.each do |date|
        serialize_date(date, xml)
      end
    }

    xml.language {
      xml.languageTerm(:type => 'code') {
        xml.text mods.language_term
      }
      
    }
    
    xml.physicalDescription{
      mods.extents.each do |extent|
        xml.extent extent
      end
    }
    
    mods.notes.each do |note|
      if note.wrapping_tag
        xml.send(note.wrapping_tag) {
          serialize_note(note, xml)
        }
      else
        serialize_note(note, xml)
      end
    end

    mods.subjects.each do |subject|
      xml.subject(:authority => subject['source']) {
        subject['terms'].each do |term|
          xml.topic term
        end
      }
    end

    xml.identifier(:type => 'local') {xml.text mods.digital_object_id} 
    
    mods.names.each do |name|

      case name['role']
      when 'subject'
        xml.subject {
          serialize_name(name, xml)
        }
      else
        if name['source']
         serialize_name(name, xml)
        end
      end
    end
    
    mods.parts.each do |part|
      xml.part(:ID => part['id']) {
        xml.detail {
          xml.title part['title']
        }
      }
    end

    # flattened tree
    mods.each_related_item do |item|
      xml.relatedItem(:type => 'constituent') {
        serialize_mods_inner(item, xml)
      }
    end

    mods.resource.each do |resource|
      xml.relatedItem(:type => 'host', :displayLabel => 'resource') {
        xml.name resource['title']
        xml.identifier resource['identifier']
      }
    end

    mods.component.each do |component|
      xml.relatedItem(:type => 'host', :displayLabel => 'component') {
        xml.name component['title']
        xml.identifier component['ref_id']
      }
    end

  end

  def serialize_date(date, xml)
    atts={}
    if(date['certainty'])
      atts['qualifier'] = date['certainty']
    end
    case date['label']
    when 'creation'
      xml.dateCreated(atts) {xml.text format_date(date)}
    when 'issued'
      xml.dateIssued(atts) {xml.text format_date(date)}
    when 'broadcast'
      xml.dateIssued(atts) {xml.text format_date(date)}
    when 'digitized'
      xml.dateCaptured(atts) {xml.text format_date(date)}
    when 'modified'
      xml.dateModified(atts) {xml.text format_date(date)}
    when 'copyright'
      xml.copyrightDate(atts) {xml.text format_date(date)}
    else 
      xml.dateOther(atts) {xml.text format_date(date)}
    end
  end

  def format_date(date)
    case date['expression']
    when nil
      case date['type']
      when 'single'
        date['begin']
      else 
        date['begin'] + '-' + date['end']
      end
    else
      date['expression']
    end
  end

end