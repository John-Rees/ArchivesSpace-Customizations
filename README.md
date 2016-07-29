# ArchivesSpace-Customizations
All local RAC Customizations for Archivesspace, including locales edits, templates, and headers.

##ead_converter.rb
We have changed `plugins/local/backend/model/ead_converter.rb` to automatically publish notes and text unless marked internal in the EAD.

##Locales
`locales/en.yml` controls tooltip customizations and wording of various different sections (Total Processing Time).
`locales/enums/en.yml` contains local changes to controlled value lists.

##as-cors
`plugins/as-cors/` adds Access-Control-Allow headers to HTTP requests using Rack middleware. Huge thanks to Mark Triggs for the assist on this plugin.

##rac_labels_model
`plugins/local/backend/model/rac_labels_model` writes customized container label data to a Tab Separated Values file as a streaming export.

##Hierarchy tree
`plugins/local/frontend/app/assets/tree.js.rb` contains a fix to the javascript hierarchy resource tree.

##my_accessions_controller.rb
`plugins/local/frontend/controllers/my_accessions_controller.rb` changes to the Accessions browse page to default to sorting by accession date descending.

##search_result_data.rb
`plugins/local/frontend/models/search_result_data.rb` changes the order of the faceting in Accessions and Digital Objects browse pages, as well as the search results.

##header_repository.html.erb
`plugins/local/frontend/views/shared/_header_repository.html.erb` changes the display of the header to remove all mention of Classifications

##plugin_init.rb
`plugins/local/frontend/plugin_init.rb` calls the search_result_data.rb changes.

##Requirements
*   ArchivesSpace

##Installation
To install the locales, navigate to your ArchivesSpace installation directory, and then overwrite /locales/en.yml and /locales/enums/en.yml.

To install the other plugins, install them in the plugins directory of ArchivesSpace, replicating the directory structure the files are in on Github.

##Usage
After installing the files, stop Archivesspace. Then make sure your config.rb file has the line "AppConfig[:plugins] = ['local',  'lcnaf', 'aspace-public-formats']" uncommented, and that it includes 'local'.

Restart ArchivesSpace

## Contributing

Please contribute! If you find an error or a better way to do this work, please submit a pull request. I'll review all pull requests and respond if I have any questions.

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## Authors

Patrick Galligan & Hillel Arnold

## License

This content is released under MIT-License. Please see `MIT-License.md` for more information.
