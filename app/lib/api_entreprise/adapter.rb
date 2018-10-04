class ApiEntreprise::Adapter
  UNAVAILABLE = 'Donnée indisponible'

  def initialize(siret, procedure_id)
    @siret = siret
    @procedure_id = procedure_id
  end

  def data_source
    @data_source ||= get_resource
  rescue
    @data_source = nil
  end

  def to_params
    if data_source.present?
      process_params
    else
      {}
    end
  end

  def valid_params?(params)
    !params.has_value?(UNAVAILABLE)
  end
end
