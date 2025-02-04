class Champs::DepartementChamp < Champs::TextChamp
  validate :value_in_departement_names, unless: -> { value.nil? }
  validate :external_id_in_departement_codes, unless: -> { external_id.nil? }

  def for_export
    [name, code]
  end

  def to_s
    formatted_value
  end

  def for_tag
    formatted_value
  end

  def for_api
    formatted_value
  end

  def for_api_v2
    formatted_value.tr('–', '-')
  end

  def selected
    code
  end

  def code
    external_id || APIGeoService.departement_code(name)
  end

  def name
    maybe_code_and_name = value&.match(/^(\w{2,3}) - (.+)/)
    if maybe_code_and_name
      maybe_code_and_name[2]
    else
      value
    end
  end

  def value=(code)
    if [2, 3].include?(code&.size)
      self.external_id = code
      super(APIGeoService.departement_name(code))
    elsif code.blank?
      self.external_id = nil
      super(nil)
    else
      self.external_id = APIGeoService.departement_code(code)
      super(code)
    end
  end

  private

  def formatted_value
    blank? ? "" : "#{code} – #{name}"
  end

  def value_in_departement_names
    return if value.in?(APIGeoService.departements.pluck(:name))

    errors.add(:value, :not_in_departement_names)
  end

  def external_id_in_departement_codes
    return if external_id.in?(APIGeoService.departements.pluck(:code))

    errors.add(:external_id, :not_in_departement_codes)
  end
end
