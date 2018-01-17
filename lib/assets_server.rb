require 'sinatra/base'
require 'sinatra/cross_origin'

class Mumukit::Server::App < Sinatra::Base
  register Sinatra::CrossOrigin

  configure do
    enable :cross_origin
  end

  def self.get_asset(route, absolute_path, type)
    get "/assets/#{route}" do
      send_file absolute_path, { type: type }
    end
  end

  def self.get_board_asset(route, path, type)
    get_asset route, Gobstones::Board.assets_path_for(path), type
  end

  def self.get_editor_asset(route, path, type)
    get_asset route, Gobstones::Blockly.assets_path_for(path), type
  end

  def self.get_local_asset(route, path, type)
    get_asset route, File.expand_path(path), type
  end

  get_board_asset  'webcomponents.js',     'javascripts/vendor/webcomponents.min.js',   'application/javascript'
  get_board_asset  'editor/editor.js',     'lib/render/editor/editor.js',               'application/javascript'
  get_board_asset  'polymer.html',         'htmls/vendor/polymer.html',                 'text/html'
  get_board_asset  'polymer-mini.html',    'htmls/vendor/polymer-mini.html',            'text/html'
  get_board_asset  'polymer-micro.html',   'htmls/vendor/polymer-micro.html',           'text/html'
  get_board_asset  'gs-board.html',        'htmls/gs-board.html',                       'text/html'
  get_editor_asset 'editor/editor.html',   'htmls/gs-element-blockly.html',             'text/html'
  get_local_asset  'editor/editor.css',    'lib/render/editor/editor.css',              'text/css'
end
