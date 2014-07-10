# -*- coding: utf-8 -*-

module Rnfse::XMLBuilder::IssNet10
  include Rnfse::XMLBuilder::Abrasf10

  private

  # prepara um hash para ser convertido a xml com o Gyoku
  def prepare_hash(hash)
    hash = camelize_hash(hash)
    hash = wrap_rps(hash)
    hash = add_tc_namespace(hash)
    hash = clean_numerics(hash)
    hash = date_to_utc(hash)
    hash = fix_booleans(hash)
    hash = wrap_cpf_cnpj(hash)    
    hash = add_municipio_prestacao_servico(hash)
    hash = add_estado(hash)
    hash = add_cidade(hash)
    hash = alter_aliquota(hash)

    hash
  end

  # alterar o formato da aliquota de 0 a 1 para 0 a 100
  def alter_aliquota(hash)
    Rnfse::Hash.transform_values(hash, 'tc:Aliquota') do |val|
      "%.2f" % (val * 100)
    end
  end

  # troca a tag Endereco/CodigoMunicipio por Cidade
  def add_cidade(hash)
    Rnfse::Hash.replace_key_values(hash, 'tc:Endereco/tc:CodigoMunicipio') do |key, value|
      { 'tc:Cidade' => value }
    end
  end

  # troca a tag Uf pela tag Estado
  def add_estado(hash)
    Rnfse::Hash.replace_key_values(hash, 'tc:Uf') do |key, value|
      { :'tc:Estado' => value } 
    end
  end

  # troca a tag CodigoMunicipio para MunicipioPrestacaoServico
  # na tag Servico
  def add_municipio_prestacao_servico(hash)
    Rnfse::Hash.replace_key_values(hash, 'tc:Servico/tc:CodigoMunicipio') do |key, value|
      { :'tc:MunicipioPrestacaoServico' => value }
    end
  end

  # encapsula as tags cpf ou cnpj em uma tag cpfcnpj
  def wrap_cpf_cnpj(hash)
    regex = /(Cpf|Cnpj)\Z/
    Rnfse::Hash.replace_key_values(hash, regex) do |key, value|
      { :'tc:CpfCnpj' => { key => value } }
    end
  end

  def xmlns
    'http://www.issnetonline.com.br/webserviceabrasf/vsd/servico_enviar_lote_rps_envio.xsd'
  end

  def xmlns_tc
    'http://www.issnetonline.com.br/webserviceabrasf/vsd/tipos_complexos.xsd'
  end  

end
