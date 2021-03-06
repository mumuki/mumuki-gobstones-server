class Mumukit::Server::App < Sinatra::Base
  include Mumukit::Server::WithAssets

  def self.get_board_asset(route, path, type)
    get_asset route, Gobstones::Board.assets_path_for(path), type
  end

  def self.get_editor_asset(route, path, type)
    get_asset route, Gobstones::Blockly.assets_path_for(path), type
  end

  def self.get_submit_asset(route, path, type)
    get_asset route, Gobstones::CodeRunner.assets_path_for(path), type
  end

  def self.get_local_svg(name, asset_type)
    get_local_asset "#{asset_type}/#{name}.svg", "lib/public/#{name}.svg", 'image/svg+xml'
  end

  def self.get_media_assets(folder, content_type = nil)
    Dir.glob(File.join(__dir__,"../lib/public/#{folder}/*")).each do |path|
      relative_media_asset_path = "#{folder}/#{File.basename path}"
      get_local_asset relative_media_asset_path, "lib/public/#{relative_media_asset_path}", content_type
    end
  end

  ['polymer', 'polymer-mini', 'polymer-micro'].each { |name|
    get_board_asset "#{name}.html", "htmls/vendor/#{name}.html", 'text/html'
  }
  get_board_asset 'gs-board.html', 'htmls/gs-board.html', 'text/html'

  get_editor_asset 'editor/gs-element-blockly.html', 'htmls/gs-element-blockly.html', 'text/html'

  get_submit_asset 'editor/gobstones-code-runner.html', 'htmls/gobstones-code-runner.html', 'text/html'

  get_local_asset 'layout/layout.html', 'lib/render/layout/layout.html', 'text/html'
  get_local_asset 'editor/editor.js', 'lib/render/editor/editor.js', 'application/javascript'
  get_local_asset 'editor/editor.css', 'lib/render/editor/editor.css', 'text/css'
  get_local_asset 'editor/hammer.min.js', 'lib/render/editor/hammer.min.js', 'application/javascript'
  get_local_asset 'boom.png', 'lib/public/boom.png', 'image/png'

  # Depracated, prefer toolbox path
  get_local_asset 'full-kindergarten-toolbox.xml', 'lib/public/full-kindergarten-toolbox.xml', 'text/plain'
  get_local_asset 'minimal-kindergarten-toolbox.xml', 'lib/public/minimal-kindergarten-toolbox.xml', 'text/plain'

  get_media_assets 'toolbox', 'text/plain'

  get_media_assets 'media'
  get_media_assets 'local-media'

  ['red', 'blue', 'green', 'black'].each do |name|
    get_local_svg(name, 'editor')
  end

  ['attires_enabled', 'attires_disabled'].each do |name|
    get_local_svg(name, 'layout')
  end

  get '/assets/editor/editor.html' do
    cross_origin
    content_type 'text/html'

    @game_framework_extra = Gobstones::CompilationMode::GameFramework.extra_code
    @game_framework_program = Gobstones::CompilationMode::GameFramework.program_code
    @game_framework_default = Gobstones::CompilationMode::GameFramework.default_code
    @assets_url = "//#{request.host_with_port}/assets"
    erb File.read(File.join(__dir__, 'render/editor/editor.html.erb'))
  end
end
