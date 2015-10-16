=begin
  Camaleon CMS is a content management system
  Copyright (C) 2015 by Owen Peredo Diaz
  Email: owenperedo@gmail.com
  This program is free software: you can redistribute it and/or modify   it under the terms of the GNU Affero General Public License as  published by the Free Software Foundation, either version 3 of the  License, or (at your option) any later version.
  This program is distributed in the hope that it will be useful,  but WITHOUT ANY WARRANTY; without even the implied warranty of  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the  GNU Affero General Public License (GPLv3) for more details.
=end
module CamaleonCms::Frontend::SeoHelper
  def init_seo(model)
    @_seo_info = model.the_seo
  end

  # add seo attributes to your page
  # you can pass custom data to overwrite default data generated by the system
  def the_seo(data = {})
    (@_seo_info ||= {}).merge(data)
  end

  # create seo attributes with options + default attributes
  def build_seo(options)
    options[:image] = options[:image] || current_site.get_option("screenshot", current_site.the_logo)
    options[:title] = I18n.transliterate(is_home? ? current_site.the_title : "#{current_site.the_title} | #{options[:title]}")
    options[:description] = I18n.transliterate(is_home? ? current_site.the_option("seo_description") : options[:description].to_s)
    options[:keywords] = I18n.transliterate(is_home? ? current_site.the_option("keywords") : options[:keywords].to_s)
    options[:url] = request.original_url
    s = {
      title: options[:title],
      description: options[:description],
      keywords: options[:keywords],
      image: options[:image],
      author: current_site.get_option('seo_author'),
      og: {
        title: options[:title],
        description: options[:description],
        type: 'website',
        url: request.original_url,
        image: options[:image]
      },
      twitter: {
        card: 'summary',
        title: options[:title],
        description: options[:description],
        url:   request.original_url,
        image: options[:image],
        site: current_site.get_option('twitter_card'),
        creator: current_site.get_option('twitter_card'),
        domain: request.host
      },
      alternate: [
        { type: 'application/rss+xml', href: rss_url }
      ]
    }

    l = current_site.get_languages
    if l.size > 1
      l.each do |lang|
        s[:alternate] << {
          href: current_site.the_url(locale: lang),
          hreflang: lang
        }
      end
    end

    # call all hooks for seo
    r = { seo_data: s, object: options[:object] }
    hooks_run('seo', r)
    r[:seo_data]
  end
end