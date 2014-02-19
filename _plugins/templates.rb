#templates.rb generates all translated pages using templates in
#_templates. The final file name of each page is defined in 
#the url section of each translations in _translations.

require 'yaml'
require 'cgi'

module Jekyll

  class TranslatePage < Page
    def initialize(site, base, lang, srcdir, src, dstdir, dst)
      @site = site
      @base = base
      @dir = '/'+dstdir
      @name = dst
      self.process(dst)
      self.read_yaml(File.join(base, srcdir), src)
      self.data['lang'] = lang
    end
  end
  class TranslatePageGenerator < Generator
    def generate(site)
      #load translations files
      locs = {}
      Dir.foreach('_translations') do |file|
        next if file == '.' or file == '..'
        lang = file.split('.')[0]
        locs[lang] = YAML.load_file("_translations/"+file)[lang]
      end
      #Generate each translated page based on templates
      if !File.directory?(site.dest)
        Dir.mkdir(site.dest)
      end
      locs.each do |lang,value|
        Dir.foreach('_templates') do |file|
          next if file == '.' or file == '..'
          id = file.split('.')[0]
          dst = locs[lang]['url'][id]
          next if dst.nil? or dst == ''
          src = file
          dst = dst+'.html'
          site.pages << TranslatePage.new(site, site.source, lang, '_templates', src, lang, dst)
        end
        site.pages << TranslatePage.new(site, site.source, lang, '_templates', 'index.html', lang, 'index.html')
      end
    end
  end

end
