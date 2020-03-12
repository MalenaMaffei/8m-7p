require 'nokogiri'
require 'mechanize'
require 'json'
require 'csv'
require 'uri'
require 'logger'
require 'getoptlong'
require_relative './utils'

$log = Logger.new(STDOUT)
$log.sev_threshold = Logger::DEBUG
$log.datetime_format = "%Y-%m-%d %H:%M:%S"
$log.formatter = Logger::Formatter.new

proyect_path = "/home/tati/Desktop/proyectos/8m-7p"


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


def process_file(total_parts, part, proyect_path)

    papers_data_path = "#{proyect_path}/scrapping/outputs/papers_data/*"
    authors_id_to_scrape = "#{proyect_path}/data/author_id_to_scrape_2.csv"
    authors_data_path = "#{proyect_path}/scrapping/outputs/authors_data/authors_#{part}_from_#{total_parts}.csv"
    influenced_by_data_path = "#{proyect_path}/scrapping/outputs/authors_data/influenced_by_#{part}_from_#{total_parts}.csv"
    influenced_authors_data_path = "#{proyect_path}/scrapping/outputs/authors_data/influenced_authors_#{part}_from_#{total_parts}.csv"
    errors_path = "#{proyect_path}/scrapping/outputs/authors_data/errors_#{part}_from_#{total_parts}.csv"



    CSV.open(authors_data_path, "wb") do |csv_authors|
    CSV.open(influenced_by_data_path, "wb") do |csv_influenced_by|
    CSV.open(influenced_authors_data_path, "wb") do |csv_influenced_authors|
    CSV.open(errors_path, "wb") do |errors|    

        csv_authors << ["author_id", "gender", "publications", "citations", "highly_influencial_citations", "prom_authors_papers", "papers_years"]
        csv_influenced_by << ["author_id", "id", "name", "score" ]
        csv_influenced_authors << ["author_id", "id", "name", "score" ]
        errors  << ["author_id", "gender", "i", "error" ]

        csv_text = File.read(authors_id_to_scrape)
        csv = CSV.parse(csv_text, :headers => true)
        
        total_rows = csv.size
        ids_per_file = (total_rows/(total_parts.to_f)).ceil
        min = ids_per_file*(part-1)
        max = min + ids_per_file
        i = 0
        csv.each do |row|
            
            author_id = row[0]
            author_gender = row[1]
            i +=1
            begin
                next if i < min
                break if i > max
                $log.debug "Waiting some secs to get next author #{i} - #{author_id} (ids from #{min} to #{max} of #{total_rows})"
                sleep 1
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
                errors << [author_id, author_gender, i, e.message]
                $log.error e.message 
                next
            end
        end
    end
    end
    end
    end
end





if $PROGRAM_NAME == __FILE__
  
    csv_in_path, csv_out_path = nil
    opts = GetoptLong.new(
        ['--help', '-h', GetoptLong::NO_ARGUMENT],
        ['--total_parts', '-t', GetoptLong::REQUIRED_ARGUMENT],
        ['--part', '-p', GetoptLong::REQUIRED_ARGUMENT] )
    
    total_parts = 1
    part = 1
    
    opts.each do |opt, arg|
    
        case opt    
            when '--total_parts'
                total_parts = arg.to_i

            when '--part'
                part = arg.to_i
        
            when '--help'        
                puts <<-HELP
                
                *******************************************************************
                *    There are two optional args:                                 *
                *                                                                 *
                *     --total_parts -t  -> qty of parts to process the doc        *
                *     --part -p         -> actual part to process                 *
                *                                                                 *
                *******************************************************************

                     HELP
                exit 0
        end
    
    end

    process_file(total_parts, part, proyect_path)
end