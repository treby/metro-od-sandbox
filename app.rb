require 'json'
require 'yaml'
require 'net/http'
require 'sinatra'
require 'haml'
set :environment, :production

SETTINGS = YAML.load_file('settings.yaml')

API_ENDPOINT   = 'https://api.tokyometroapp.jp/api/v2/'
DATAPOINTS_URL = API_ENDPOINT + "datapoints"
ACCESS_TOKEN   = SETTINGS['token']

get '/', provides: 'html' do
  haml :index
end

get '/stations', provides: 'html' do
  uri = URI.parse('%s?rdf:type=odpt:Station&acl:consumerKey=%s'%[DATAPOINTS_URL, ACCESS_TOKEN])

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  res = https.start do
    https.get(uri.request_uri)
  end

  @stations = []
  JSON.parse(res.body).each do |line|
    title = line['dc:title']
    railway = line['odpt:railway'].split(':').last
    code = line['odpt:stationCode']

    station_info = {
      code: code,
      railway: railway,
      title: title
    }

    @stations.push(station_info)
  end

  haml :stations
end

get '/stations/:name', provides: 'html' do
  uri = URI.parse('%s?rdf:type=odpt:Station&owl:sameAs=%s&acl:consumerKey=%s'%[DATAPOINTS_URL, params[:name], ACCESS_TOKEN])

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  res = https.start do
    https.get(uri.request_uri)
  end

  @stations = []
  JSON.parse(res.body).each do |line|
    title = line['dc:title']
    railway = line['odpt:railway'].split(':').last
    code = line['odpt:stationCode']

    station_info = {
      code: code,
      railway: railway,
      title: title
    }

    @stations.push(station_info)
  end

  haml :stations
end

get '/railways/', provides: 'html' do
  uri = URI.parse('%s?rdf:type=odpt:Railway&acl:consumerKey=%s'%[DATAPOINTS_URL, ACCESS_TOKEN])

  https = Net::HTTP.new(uri.host, uri.port)
  https.use_ssl = true
  res = https.start do
    https.get(uri.request_uri)
  end

  @railways = []
  JSON.parse(res.body).each do |line|
    linecode = line['odpt:linecode']
    title = line['dc:title']
    station_list = line['odpt:stationOrder']

    railway_info = {
      linecode: linecode,
      title: title,
      station_list: station_list
    }

    @railways.push(railway_info)
  end
  haml :railways
end
