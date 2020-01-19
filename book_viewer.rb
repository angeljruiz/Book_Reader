require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

helpers do
  def in_paragraphs(text)
    results = []
    text.split("\n\n").each.with_index do |sentence, index|
      results << "<p id='#{index}'>#{sentence}</p>"
    end
    results.join
  end

  def get_paragraphs(arr, chapter)
    chapter = File.read("data/chp#{chapter + 1}.txt").split("\n\n")
    arr.map! do |item|
      item = chapter[item].gsub("\n", " ")
    end
  end

  def highlight(text, term)
    text.gsub(term, %(<strong>#{term}</strong>))
  end
end

before do
  @contents = File.readlines("data/toc.txt")
end

not_found do
  redirect '/'
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get '/search' do
  @query = params[:query]
  @chapters = 1.upto(12).map { |number| File.read("data/chp#{number}.txt")}
  @chapters.map!.with_index { |chapter, index| results = []; chapter.split("\n\n").each.with_index do |p, i|
    results << i if p.include?((@query || '').downcase)
  end; get_paragraphs(results, index)}
  @found = !@chapters.none? { |arr| arr.size > 0 }
  erb :search
end

get "/chapters/:number" do
  number = params[:number].to_i
  chapter_name = @contents[number - 1]

  redirect "/" unless (1..@contents.size).cover? number

  @title = "Chapter #{number}: #{chapter_name}"

  @chapter = File.read("data/chp#{number}.txt")

  erb :chapter
end
