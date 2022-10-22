require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do
  @toc = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n")
  end

  def embolden(query, text)
    text.gsub(query, "<strong>#{query}</strong>")
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapter/:number" do
  number = params[:number].to_i
  chapter_name = @toc[number - 1]

  redirect "/" unless (1..@toc.size).cover?(number)

  @title = "Chapter #{number}: #{chapter_name}"
  @text = File.read("data/chp#{number}.txt")

  erb :chapter
end

not_found do
  redirect "/"
end

get "/search" do
  @title = "The Adventures of Sherlock Holmes"
  @query = params[:query]
  if @query
    @results = matching_chapters(@query)
  end

  erb :search
end

def each_chapter
  @toc.each_with_index do |chap_title, i|
    chap_number = i + 1
    chap_text = File.read("data/chp#{chap_number}.txt")
    yield chap_title, chap_number, chap_text
  end
end

def matching_chapters(query)
  matches = []
    
  each_chapter do |title, number, text|
    if text.downcase.include?(query.downcase)
      matches << {title: title, number: number, text: text} 
    end
  end

  matches.each do |chap_hash|
    paragraphs = matching_paragraphs(chap_hash[:text], query)
    chap_hash[:paragraphs] = paragraphs
  end

  matches
end

def matching_paragraphs(chap_text, query)
  results = []
  chap_text.split("\n\n").each_with_index do |paragraph, i|
    if paragraph.downcase.include?(query.downcase)
      results << {text: paragraph, id: i + 1}
    end
  end
  results
end
