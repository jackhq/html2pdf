require 'rubygems'
require 'sinatra'
require 'activerecord'
require 'base64'

####################################################
#
#  JRS HtmlDoc WebService
#
#  The purpose of this service 
#  is to convert an html string to a pdf bytecode
#  and to return the pdf to the client.
#
#
#####################################################
use Rack::Auth::Basic do |username, password|
  [username, password] == ['76a05e277f','']
end

configure do

end

helpers do 
  def base_url
    if Sinatra::Application.port == 80
      "http://#{Sinatra::Application.host}/"
    else
      "http://#{Sinatra::Application.host}:#{Sinatra::Application.port}/"
    end
  end
    
  def rfc_3339(timestamp)
    timestamp.strftime("%Y-%m-%dT%H:%M:%SZ")
  end
  
end

get '/' do
  "This is the Jack Russell Service that converts html2pdf..."
end

post '/' do
  begin
    # process image
    output_pdf = convert_to_pdf(params[:html_contents])

    content_type 'application/xml'
    builder do |xml|
      xml.pdf do
        xml.contents output_pdf
        xml.updated(rfc_3339(Time.now))
      end
    end
  rescue
   status(412)  
   "Error: All Parameters are required!\nPlease make sure you are submitting the correct parameters\n"
  end
  
  
end


def convert_to_pdf(contents)
  unique_html = "HTML" + Time.now.strftime("%m%d%Y%H%M%S") + ".html"
  unique_pdf = "PDF" + Time.now.strftime("%m%d%Y%H%M%S") + ".pdf"
  File.open(unique_html, "wb") { |f| f.write(contents) }
  
  result = system("/usr/bin/htmldoc --webpage -f #{unique_pdf} #{unique_html}")
  if result
    pdf_contents = Base64.encode64(open("#{unique_pdf}").read )
  else
    pdf_contents = ""
  end
  
  File.delete(unique_html)
  File.delete(unique_pdf) 
  return pdf_contents

end
