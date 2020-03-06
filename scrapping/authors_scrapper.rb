require 'nokogiri'
require 'mechanize'
require 'json'
require 'csv'
require 'uri'
require 'logger'
require_relative './utils'

$log = Logger.new(STDOUT)
$log.sev_threshold = Logger::DEBUG
$log.datetime_format = "%Y-%m-%d %H:%M:%S"
$log.formatter = Logger::Formatter.new

papers_data_path = "/home/tati/Desktop/proyectos/8m-7p/scrapping/outputs/papers_data/*"
authors_id_to_scrape = "/home/tati/Desktop/proyectos/8m-7p/data/author_id_to_scrape_2.csv"
authors_data_path = "/home/tati/Desktop/proyectos/8m-7p/scrapping/outputs/authors_data/authors.csv"
influenced_by_data_path = "/home/tati/Desktop/proyectos/8m-7p/scrapping/outputs/authors_data/influenced_by.csv"
influenced_authors_data_path = "/home/tati/Desktop/proyectos/8m-7p/scrapping/outputs/authors_data/influenced_authors.csv"

def get_authors_id_from_files(papers_data_path)
    file_names = Dir[papers_data_path]
    authors_ids = []
    file_names.each do |file|
        csv_text = File.read(file)
        csv = CSV.parse(csv_text, :headers => true)
        csv.each do |row|
            data = row[5]
            authors_data = data.gsub("\"id\":nil,","\"id\":\"nil\",").split("||").map{ |ad| JSON.parse ad}.map{|a| a["id"]}
            authors_ids.concat authors_data
            authors_ids = authors_ids.uniq
        end
    end
    authors_ids.delete("nil")
    authors_ids
end

def authors_id_to_files(papers_data_path, authors_data_path)
    authors_ids = get_authors_id_from_files(papers_data_path)
    File.open("#{authors_data_path}/ids.txt", "w+") do |f|
        authors_ids.each { |id| f.puts(id) }
        $log.info "Successfully saved #{authors_ids.size} authors ids"
    end
end

def get_statistics_data(author_id, gender, page, data_json)
    stadistic_data = page.xpath('//div[@class="author-detail-card"]//div[@class="author-detail-card__stats-row"]/span')
    publications = stadistic_data[1].text.gsub(",","")
    citations = stadistic_data[3].text.gsub(",","")
    highly_influencial_citations = stadistic_data[5].text.gsub(",","")
    authors_qty = 0
    years = []
    papers = data_json[1]["resultData"]["author"]["papers"]["results"]
    papers_qty = papers.length()
    papers.each do |paper|
        authors_qty += paper["authors"].length()
        years.push(paper["year"]["text"].strip)
    end
    prom_authors_papers = authors_qty / papers_qty

    {"author_id" => author_id, "gender" => gender, "publications" => publications, "citations" => citations, "highly_influencial_citations" => highly_influencial_citations, "prom_authors_papers" => prom_authors_papers, "years" => years.join(",")  }
end

def get_author_data(author_id,a)
    author = { "author_id" => author_id, "id" => a["author"]["ids"].first, "name" => a["author"]["name"], "score" => a["score"]}
    author
end




CSV.open(authors_data_path, "wb") do |csv_authors|
CSV.open(influenced_by_data_path, "wb") do |csv_influenced_by|
CSV.open(influenced_authors_data_path, "wb") do |csv_influenced_authors|

    csv_authors << ["author_id", "gender", "publications", "citations", "highly_influencial_citations", "prom_authors_papers", "papers_years"]
    csv_influenced_by << ["author_id", "id", "name", "score" ]
    csv_influenced_authors << ["author_id", "id", "name", "score" ]

    csv_text = File.read(authors_id_to_scrape)
    csv = CSV.parse(csv_text, :headers => true)
    i = 0
    csv.each do |row|
        
        author_id = row[0]
        author_gender = row[1]
        i +=1
        begin
            $log.debug "Waiting some secs to get next author #{i} - #{author_id}" if i%10==0
            #sleep 3
            page = get_page_from_url("https://www.semanticscholar.org/author/#{author_id}")

            data = page.at_xpath('//script[contains(text(),"var DATA =")]').text.gsub("var DATA = '","").gsub("';","")
            raw_data = Base64.decode64(data)
            data_json = JSON.parse URI.decode raw_data

            statistics = get_statistics_data(author_id, author_gender, page, data_json)
            csv_authors << statistics.values

            authors_influenced_info = data_json[1]["resultData"]["author"]["statistics"]["influence"]["influenced"]
            who_influenced_author_info = data_json[1]["resultData"]["author"]["statistics"]["influence"]["influencedBy"]

            authors_influenced_info.each do |a|
                author = get_author_data(author_id,a)
                csv_influenced_by << author.values
            end

            who_influenced_author_info.each do |a|
                author = get_author_data(author_id,a)
                csv_influenced_authors << author.values
            end
        rescue => e
            $log.error e.message
            next
        end
    end
end
end
end

