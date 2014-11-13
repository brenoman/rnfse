# -*- coding: utf-8 -*-

module Rnfse::XMLBuilder::Abrasf10

  module ClassMethods

    def build_recepcionar_lote_rps_xml(hash = {})
      build_xml('EnviarLoteRpsEnvio', hash)
    end

    def build_consultar_situacao_lote_rps_xml(hash = {})
      build_xml('ConsultarSituacaoLoteRpsEnvio', hash)
    end

    def build_consultar_nfse_por_rps_xml(hash = {})
      build_xml('ConsultarNfseRpsEnvio', hash)
    end

    def build_consultar_nfse_xml(hash = {})
      raise Rnfse::Error::NotImplemented
    end

    def build_consultar_lote_rps_xml(hash = {})
      build_xml('ConsultarLoteRpsEnvio', hash)
    end

    def build_cancelar_nfse_xml(hash = {})
      raise Rnfse::Error::NotImplemented
    end

    private

    def build_xml(wrapper, hash = {})
      hash = prepare_hash(hash)
      inner_xml = ::Gyoku.xml(hash, key_converter: :none)
      xml_builder(wrapper, inner_xml).doc
    end

    # prepara um hash para ser convertido a xml com o Gyoku
    def prepare_hash(hash)
      hash = camelize_hash(hash)
      hash = wrap_rps(hash)
      hash = add_tc_namespace(hash)
      hash = clean_numerics(hash)
      hash = date_to_utc(hash)
      hash = fix_booleans(hash)
      hash
    end
    
    # converte booleanos para 1 ou 2
    def fix_booleans(hash)
      regex = /((?<!Valor)IssRetido|OptanteSimplesNacional|IncentivadorCultural)\Z/
      Rnfse::Hash.transform_values(hash, regex) do |val|
        val ? 1 : 2
      end
    end
      
    # converte datas para GMT-0
    def date_to_utc(hash)
      Rnfse::Hash.transform_values(hash, /DataEmissao\Z/) do |val|
        DateTime.parse(val.to_s).new_offset(0).strftime('%FT%T')
      end
    end

    # limpa tags que por precaução é melhor só conter números
    def clean_numerics(hash)
      regex = /(Cep|Cnae|Cpf|Cnpj)\Z/
      Rnfse::Hash.transform_values(hash, regex) { |val| val.gsub(/\D/, '') }
    end
    
    # converte as chaves do hash para CamelCase
    def camelize_hash(hash)
      Rnfse::Hash.camelize_and_symbolize_keys(hash)
    end

    # encapsula as rps dentro de listaRps com Rps/InfRps
    def wrap_rps(hash)
      hash[:LoteRps][:ListaRps] = {
        :Rps => { :InfRps => hash[:LoteRps][:ListaRps] }
      } if hash[:LoteRps]
      hash
    end

    # adiciona o namespace tc nas tags dentro de loteRps ou prestador
    def add_tc_namespace(hash)
      regex = /\A(LoteRps|Prestador|IdentificacaoRps)\Z/
      Rnfse::Hash.replace_key_values(hash, regex) do |key, value|
        { key => Rnfse::Hash.transform_keys(value) { |k| "tc:#{k}".to_sym } }
      end
    end

    # namespace dos tipos complexos
    def xmlns_tc
      'http://www.abrasf.org.br/tipos_complexos.xsd'
    end  

    # namespaces do xml recepcionar_lote_rps
    def build_recepcionar_lote_rps_xmlns
      {
        'xmlns' => 'http://www.abrasf.org.br/servico_enviar_lote_rps_envio.xsd',
        'xmlns:tc' => xmlns_tc
      }
    end

    # namespaces do xml consultar_lote_rps
    def build_consultar_lote_rps_xmlns
      {
        'xmlns' => 'http://www.abrasf.org.br/servico_consultar_lote_rps_envio.xsd',
        'xmlns:tc' => xmlns_tc
      }
    end

    # namespaces do xml consultar_situacao_lote_rps
    def build_consultar_situacao_lote_rps_xmlns
      {
        'xmlns' => 'http://www.abrasf.org.br/servico_consultar_situacao_lote_rps_envio.xsd',
        'xmlns:tc' => xmlns_tc
      }
    end

    # namespaces do xml consultar_nfse_por_rps
    def build_consultar_nfse_por_rps_xmlns
      {
        'xmlns' => 'http://www.abrasf.org.br/servico_consultar_situacao_lote_rps_envio.xsd',
        'xmlns:tc' => xmlns_tc
      }
    end

    # instancia o builder a ser utilizado na geracao do xml
    def xml_builder(root, inner_xml, xmlns = {})
      xmlns = self.send("#{Rnfse::CallChain.caller_method(2)}ns") if xmlns.empty?
      Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.send(root.to_sym, xmlns) do
          xml << inner_xml
        end
      end
    end
  end

  extend ClassMethods

  def self.extended(base)
    base.extend(ClassMethods)
  end

  def self.included(base)
    base.send(:include, ClassMethods)
  end

end
