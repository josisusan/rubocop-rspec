# frozen_string_literal: true

module RuboCop
  module RSpec
    # Wrapper for RSpec examples
    class Example
      extend RuboCop::NodePattern::Macros

      def_node_matcher :extract_doc_string,     '(send _ _ $str ...)'
      def_node_matcher :extract_metadata,       '(send _ _ _ $...)'
      def_node_matcher :extract_implementation, '(block send args $_)'

      def initialize(node)
        @node = node
      end

      def doc_string
        extract_doc_string(definition)
      end

      def metadata
        extract_metadata(definition)
      end

      def implementation
        extract_implementation(node)
      end

      def eql?(other)
        node.eql?(other.node)
      end

      alias == eql?

      def hash
        [self.class, node].hash
      end

      def to_node
        node
      end

      def definition
        if node.send_type?
          node
        else
          node.children.first
        end
      end

      protected

      attr_reader :node
    end
  end
end
