module DataDefinitions
  class Base
    attr_accessor :name, :document

    # rubocop:disable Metrics/AbcSize
    def initialize
      @name = self.class.name.underscore.split('/').last
      xml_file = format('%s.xml', @name)
      xml_path = Rails.root.join('app', 'data_definitions', 'from_cascade', xml_file)
      @document = Nokogiri::XML(File.read(xml_path)) if File.exist?(xml_path)
      @data_document = Nokogiri::XML(self.class::CASCADE_DATA.to_xml) \
        if self.class.const_defined?('CASCADE_DATA')
    end
    # rubocop:enable Metrics/AbcSize

    def set_defaults
      self.class::DEFAULTS.each do |xpath, value|
        node = @document.at_xpath(xpath)
        raise "Node at xpath #{xpath} not found." unless node
        node.content = value
      end
    end

    # rubocop:disable Rails/OutputSafety
    def get_child_value(field, unescaped=false)
      node = get_child(field)
      value = node.content
      unescaped ? value.html_safe : value
    end
    # rubocop:enable Rails/OutputSafety

    def set_value(field, value)
      node = get_child(field)
      node.content = value
    end

    def get_child(field)
      xpath = self.class::XPATH[field]
      raise "There is no xpath set for field #{field}." unless xpath

      node = document.at_xpath(xpath)
      raise "Node at xpath #{xpath} not found." unless node

      node
    end

    def select_single_node_value(xpath)
      # Mirrors Cascade Velocity helper: $_XPathTool.selectSingleNode(node, xpath).value
      # Returns string value.
      xpath = format('//%s', xpath) unless xpath.start_with?('/')
      node = @data_document.at_xpath(xpath)
      node.nil? ? '' : node.content
    end

    def select_nodes(xpath)
      # Mirrors Cascade Velocity helper: $_XPathTool.selectNodes(node, xpath).
      # Returns DataDefinitions:NodeSet array.
      xpath = format('//%s', xpath) unless xpath.start_with?('/')
      @data_document.xpath(xpath)
    end
  end

  # Extend Nokogiri Nodeset
  module NokogiriExtensions
    module Element
      def select_single_node_value(xpath)
        node = at_xpath(xpath)
        raise "Node not found for xpath #{xpath}." unless node
        node.content
      end
    end
  end

  # Monkey-patch it now!
  Nokogiri::XML::Element.include DataDefinitions::NokogiriExtensions::Element
end
