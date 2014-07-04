# -*- coding: utf-8 -*-
require 'spec_helper'

describe Rnfse::API::Abrasf_1_0 do
  let(:client) do
    Rnfse::API.new(padrao: :abrasf_1_0, 
                   namespace: 'http://www.issnetonline.com.br/webservice/nfd',
                   endpoint: 'http://www.issnetonline.com.br/webserviceabrasf/homologacao/servicos.asmx')
  end


  describe '#recepcionar_lote_rps'
  describe '#consulta_situacao_lote_rps'
  describe '#consultar_nfse_por_rps'
  describe '#consultar_nfse'
  describe '#consultar_lote_rps'
  describe '#cancelar_nfse'
end
