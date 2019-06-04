# This specialized ZPLII printer aims to provide a quick way to leverage
# the existing gem code to get a ZPL label without getting bogged down in
# fixing the overall gem.  When calling Endicia.get_label(ImageFormat: 'ZPLII')
# you'll get one of these back.  Pass :image to get the unpacked ZPLII text.
#
module Endicia
  class LabelError < Exception; end

  class ZPLIILabel < Label
    attr_reader :tracking_number

    def initialize(result)
      self.response_body = filter_response_body(result.body.dup)
      data               = result["LabelRequestResponse"] || {Label: {}}
      encoded_zpl        = data["Base64LabelImage"] || data["Label"]["Image"]

      if (data.nil? || encoded_zpl.nil?)
        raise LabelError, (data["ErrorMessage"] || result.body.to_s)
      end

      if encoded_zpl.is_a?(Array)
        encoded_zpl = data["Label"]["Image"].map{|label| label["__content__"]}.join("&:surlysquid:&")
      elsif encoded_zpl.is_a?(Hash)
        encoded_zpl = data["Label"]["Image"]["__content__"]
      end


      @tracking_number   = data["TrackingNumber"]
      @image             = encoded_zpl
    end
  end
end
