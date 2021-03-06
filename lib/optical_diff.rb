require 'optical_diff/version'
require 'diffy'
require 'nokogiri'

class OpticalDiff
  class << self
    def diff(html1, html2, options = {})
      options = {
        :replace => [],
        :ignore => []
      }.merge(options)

      replaced_htmls = [html1, html2].map {|html| replace(html, options[:replace]) }
      parsed_htmls = replaced_htmls.map {|html| Nokogiri::HTML.parse(html) }
      stripped_htmls = parsed_htmls.map {|html| strip_ignore_elements(html, options[:ignore]) }
      DiffResult.new(Diffy::Diff.new(*stripped_htmls.map(&:to_html)))
    end

    def replace(page, patterns = [])
      page = page.dup
      patterns.each do |pattern, replace|
        page.gsub!(pattern, replace)
      end
      page
    end

    def strip_ignore_elements(page, ignore = [])
      ignore.each do |selector|
        page.search(selector).remove
      end
      page
    end
    private :strip_ignore_elements
  end

  class DiffResult
    def initialize(diff)
      @diff = diff
    end

    def changes
      @diff.select {|line| line =~ /^[+-]/ }
    end

    def changed?
      changes.size > 0
    end
  end
end
