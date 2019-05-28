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

      if encoded_zpl.is_a?(String)
        decoded_zpl = Base64.decode64(encoded_zpl)
      elsif encoded_zpl.is_a?(Array)
        decoded_zpl = data["Label"]["Image"].map{|label| Base64.decode64(label["__content__"])}.join("")
      elsif encoded_zpl.is_a?(Hash)
        decoded_zpl = Base64.decode64(data["Label"]["Image"]["__content__"])
      end


      @tracking_number   = data["TrackingNumber"]
      @image             = decoded_zpl
    end
  end
end
