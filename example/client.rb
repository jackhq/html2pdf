require 'rest_client'
require 'rexml/document'
require 'open-uri'
require 'base64'

def convert(url_params)
  
  html_contents = RestClient.get url_params
  puts html_contents
  #resource = RestClient::Resource.new('http://76a05e277f@htmldoc.jackfile.com', :timeout => 1000000)
  resource = RestClient::Resource.new('http://76a05e277f@htmldoc.jackfile.com:9292', :timeout => 1000000)

  response = resource.post(:html_contents =>  html_contents)
  doc = REXML::Document.new(response)  
  puts doc
  return Base64.decode64(doc.elements['/pdf/contents'].text)
  
end

File.open('google.pdf', 'wb').write(convert('http://www.google.com'))
