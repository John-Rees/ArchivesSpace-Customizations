# as-cors

An ArchivesSpace plugin that adds Access-Control-Allow headers to HTTP requests using Rack middleware. Huge thanks to Mark Triggs for the assist on this code.

## Requirements

*   ArchivesSpace instance

## Installation

1.  Download or clone this repository into the ArchivesSpace `plugins/` directory..

        git clone git@github.com:RockefellerArchiveCenter/as-cors.git

2.  Edit `config/config.rb` to include the plugin:

        AppConfig[:plugins] = ['local',  'lcnaf', 'aspace-public-formats', 'as-cors']

3.  Restart ArchivesSpace.

## Usage

Routes on which CORS headers are available can be edited by changing the `CORS_ENDPOINTS` variable. For production use, `headers["Access-Control-Allow-Origin"]` should specify a host name, rather than the permissive wildcard `*`.

## Contributing

Pull requests accepted!

## Authors

*   Mark Triggs
*   Hillel Arnold

## License

This code is released under the MIT License. See `LICENSE.md` for more information.
