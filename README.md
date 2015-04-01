# ArchivesSpace-Customizations
All local RAC Customizations

config/config.rb controls the backend configuration of the system. Possible changes could include database name (dev vs production server), plugins to load and order, and any changes to LDAP.

locales/en.yml controls tooltip customizations and wording of various different sections (Total Processing Time).
locales/enums/en.yml contains local changes to controlled value lists.

plugins/local/frontend/app/assets/tree.js.rb contains a fix to the javascript hierarchy resource tree.
plugins/local/frontend/controllers/my_accessions_controller.rb changes to the Accessions browse page to default to sorting by accession date descending.
plugins/local/frontend/models/search_result_data.rb changes the order of the faceting in Accessions and Digital Objects browse pages, as well as the search results.
plugins/local/frontend/views/shared/_header_repository.html.erb	changes the display of the header to remove all mention of Classifications
plugins/local/frontend/plugin_init.rb calls the search_result_data.rb changes.
