require 'nokogiri'
require 'mechanize'
require 'json'
require 'csv'
require_relative './utils'

$log = Logger.new(STDOUT)
$log.sev_threshold = Logger::DEBUG
$log.datetime_format = "%Y-%m-%d %H:%M:%S"
$log.formatter = Logger::Formatter.new

def get_page_from_semantics(query_string, min_year, max_year, page, headers)
    params = "{\"queryString\":\"#{query_string}\",\"page\":#{page},\"pageSize\":500,\"sort\":\"relevance\",\"authors\":[],\"coAuthors\":[],\"venues\":[],\"yearFilter\":{\"min\":#{min_year},\"max\":#{max_year}},\"requireViewablePdf\":false,\"fieldOfStudy\":\"computer-science\",\"performTitleMatch\":true}"           
    $log.debug "Waiting some secs to get next term \"#{query_string}\""
    sleep 5
    html_page = post_page_from_url("https://www.semanticscholar.org/api/1/search", params, headers)
    page = JSON.parse html_page.body
    page
end

def get_info_from_paper(paper_info, query_string)

    id = paper_info["id"]
    title = paper_info["title"]["text"]
    abstract = paper_info["paperAbstract"]["text"]
    pub_date = paper_info["pubDate"]
    pub_year = paper_info["year"]["text"]

    authors = []
    paper_info["authors"].each_with_index do |author_data,i|
        name = author_data[0]["name"]
        id = author_data[0]["ids"].first
        url_name = author_data[0]["slug"]
        first_name = paper_info["structuredAuthors"][i]["firstName"]
        authors << {"name" => name, "first_name" => first_name, "id" => id, "url_name" => url_name}
    end

    authors = authors.map{ |a| a.to_s.gsub("=>",":")}.join "||"

    citations = paper_info["citationStats"]["numCitations"]
    keyCitations = paper_info["citationStats"]["numKeyCitations"]
    references = paper_info["citationStats"]["numReferences"]
    keyReferences = paper_info["citationStats"]["numKeyReferences"]
    citationRate = paper_info["citationStats"]["citationVelocity"]
    citationAcceleration = paper_info["citationStats"]["citationAcceleration"]
    fieldsOfStudy = paper_info["fieldsOfStudy"].join "||"

    data = [id, title, abstract, pub_date, pub_year, authors, citations, keyCitations, references, keyReferences, citationRate, citationAcceleration, fieldsOfStudy, query_string]

    data
end


periods = [[2010,2012],[2013,2015],[2016,2020]]
queryStrings = ["computer", "algorithm", "model", "cpu", "architecture", "performance", "machine learning", "blockchain", "Technology", "systems", "network", "novel", "approach"]
papers_ids = []
headers = {"Origin" => "https://www.semanticscholar.org", "Content-Type" => "application/json", "Accept" => "*/*"}

periods.each do |period|
    min_year = period.first
    max_year = period.last
    $log.info "Starting getting papers info from #{min_year} to #{max_year}"
    CSV.open("/home/tati/Desktop/proyectos/8m-7p/scrapping/outputs/papers_data/papers_#{min_year}_#{max_year}.csv", "wb") do |csv|
        csv << ["id", "title", "abstract", "pub_date", "pub_year", "authors", "citations", "keyCitations", "references", "keyReferences", "citationRate", "citationAcceleration", "fieldsOfStudy", "search_term"]
        queryStrings.each do |query_string|
            page_num = 1
            needs_other_page = true
            papers = []

            while needs_other_page do
                page = get_page_from_semantics(query_string, min_year, max_year, page_num, headers)
        
                page["results"].each do |paper_info|
                    begin  
                        next if papers_ids.include? paper_info["id"]
                        if papers.size < 500
                            data = get_info_from_paper(paper_info, query_string)
                            papers  << data
                            papers_ids << paper_info["id"]
                            csv << data
                        else
                            break
                        end 
                    rescue
                        next
                    end
                end
                $log.info "Succesfully added info for #{papers.size} papers to file"
                needs_other_page = papers.size < 500 && page["results"] != 0
                page_num += 1

            end

        end
    end
end



