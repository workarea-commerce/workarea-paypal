module Workarea
  class Payment
    class NullAddress
      class NullCountry < OpenStruct
        def to_s; end
      end

      include Mongoid::Document

      FIELDS = Workarea::Payment::Address.fields.keys.tap { |k| k.delete('_id') }

      attr_writer :reference
      attr_reader *FIELDS, :region_name

      delegate *FIELDS.map { |f| "#{f}=" }, :assign_attributes, :attributes=,
        :allow_po_box?, to: :reference

      def reference
        @reference ||= Workarea::Payment::Address.new
      end

      def save(*args)
        true
      end

      def country
        NullCountry.new
      end

      def falsey(*args)
        false
      end
      alias :po_box? :falsey
      alias :address_eql? :falsey
    end
  end
end
