class APIGeoService
  class << self
    def countries(locale: I18n.locale)
      I18nData.countries(locale)
        .merge(get_localized_additional_countries(locale))
        .map { |(code, name)| { name:, code: } }
        .sort_by { I18n.transliterate(_1[:name].tr('î', 'Î')) }
    end

    def country_name(code, locale: I18n.locale)
      countries(locale:).find { _1[:code] == code }&.dig(:name)
    end

    def country_code(name)
      return if name.nil?
      code = I18nData.country_code(name) || I18nData.country_code(name.humanize) || I18nData.country_code(name.titleize)
      if code.nil?
        countries_index_fr[I18n.transliterate(name).upcase]&.dig(:code)
      else
        code
      end
    end

    def regions
      get_from_api_geo(:regions).sort_by { I18n.transliterate(_1[:name]) }
    end

    def region_name(code)
      regions.find { _1[:code] == code }&.dig(:name)
    end

    def region_code(name)
      return if name.nil?
      regions.find { _1[:name] == name }&.dig(:code)
    end

    def departements
      [{ code: '99', name: 'Etranger' }] + get_from_api_geo(:departements).sort_by { _1[:code] }
    end

    def departement_name(code)
      departements.find { _1[:code] == code }&.dig(:name)
    end

    def departement_code(name)
      return if name.nil?
      departements.find { _1[:name] == name }&.dig(:code)
    end

    def epcis(departement_code)
      get_from_api_geo("epcis-#{departement_code}").sort_by { I18n.transliterate(_1[:name]) }
    end

    def epci_name(departement_code, code)
      epcis(departement_code).find { _1[:code] == code }&.dig(:name)
    end

    def epci_code(departement_code, name)
      epcis(departement_code).find { _1[:name] == name }&.dig(:code)
    end

    def communes(departement_code)
      get_from_api_geo("communes-#{departement_code}").sort_by { I18n.transliterate([_1[:name], _1[:postal_code]].join(' ')) }
    end

    def communes_by_postal_code(postal_code)
      communes_by_postal_code_map.fetch(postal_code, [])
        .sort_by { I18n.transliterate([_1[:name], _1[:postal_code]].join(' ')) }
    end

    def commune_name(departement_code, code)
      communes(departement_code).find { _1[:code] == code }&.dig(:name)
    end

    def commune_code(departement_code, name)
      communes(departement_code).find { _1[:name] == name }&.dig(:code)
    end

    private

    def communes_by_postal_code_map
      Rails.cache.fetch('api_geo_communes', expires_in: 1.day, version: 3) do
        departements
          .filter { _1[:code] != '99' }
          .flat_map { communes(_1[:code]) }
          .group_by { _1[:postal_code] }
      end
    end

    def get_from_api_geo(scope)
      Rails.cache.fetch("api_geo_#{scope}", expires_in: 1.day, version: 3) do
        JSON.parse(Rails.root.join('lib', 'data', 'api_geo', "#{scope}.json").read, symbolize_names: true)
      end
    end

    def countries_index_fr
      Rails.cache.fetch('countries_index_fr', expires_in: 1.week) do
        countries(locale: 'FR').index_by { I18n.transliterate(_1[:name]).upcase }
      end
    end

    def get_localized_additional_countries(locale)
      additional_countries[locale.to_s.upcase] || {}
    end

    def additional_countries
      {
        'FR' => { 'XK' => 'Kosovo' },
        'EN' => { 'XK' => 'Kosovo' }
      }
    end
  end
end
