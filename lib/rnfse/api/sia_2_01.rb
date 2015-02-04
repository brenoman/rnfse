# -*- coding: utf-8 -*-

module Rnfse::API::Sia201
  include Rnfse::API::Abrasf202

  def recepcionar_lote_rps(hash = {})
    xml = xml_builder.build_recepcionar_lote_rps_xml(hash)

    xml.search('ListaRps/Rps').each do |elem|
      xml_string = elem.first_element_child.to_xml(
                     save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
      doc = Nokogiri::XML(xml_string)
      doc.sign!(certificate: File.read(self.certificate), key: File.read(self.key))
      doc.root.last_element_child.xpath('//text()').each { |n| n.remove if n.content =~ /^\s*$/ }
      reference = nil
      doc.root.last_element_child.traverse { |node| reference = node if node.name == 'Reference' }
      id = doc.at('InfDeclaracaoPrestacaoServico')['Id']
      reference['URI'] = "##{id}"

      elem.add_child(doc.root.last_element_child.unlink)
    end
    xml.sign!(certificate: File.read(self.certificate), key: File.read(self.key))
    xml.root.last_element_child.xpath('//text()').each { |n| n.remove if n.content =~ /^\s*$/ }
    reference = nil
    xml.root.last_element_child.traverse { |node| reference = node if node.name == 'Reference' }
    id = xml.at('LoteRps')['Id']
    reference['URI'] = "##{id}"
    
    plain_xml = xml.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::NO_DECLARATION).strip
    xml = Nokogiri::XML::DocumentFragment.parse(plain_xml)

    username = Nokogiri::XML::Node.new('username', xml)
    username.content = '01001001000113'
    password = Nokogiri::XML::Node.new('password', xml)
    password.content = '123456'
    xml.first_element_child.add_next_sibling(username)
    xml.first_element_child.add_next_sibling(password)

    response = self.soap_client.call(
      :recepcionar_lote_rps,
      soap_action: 'recepcionarLoteRps',
      message_tag: 'ws:recepcionarLoteRps',
      message: xml.to_xml)
  end

  private

  def savon_client_options
    {
      soap_version: 1,
      env_namespace: :soapenv,
      namespaces: { 'xmlns:soapenv' => 'http://schemas.xmlsoap.org/soap/envelope/',
                    'xmlns:ws' => 'http://ws.issweb.fiorilli.com.br/',
                    'xmlns' => '' },
      namespace_identifier: nil,
      ssl_verify_mode: :peer,
      ssl_cert_file: self.certificate,
      ssl_cert_key_file: self.key,
      endpoint: self.endpoint,
      namespace: self.namespace
    }
  end

end

