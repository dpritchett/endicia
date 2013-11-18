# This specialized ZPLII printer aims to provide a quick way to leverage
# the existing gem code to get a ZPL label without getting bogged down in
# fixing the overall gem.  When calling Endicia.get_label(ImageFormat: 'ZPLII')
# you'll get one of these back.  Pass :image to get the unpacked ZPLII text.
#
module Endicia
  class LabelError < Exception; end

  class ZPLIILabel < Label
    def initialize(result)
      self.response_body = filter_response_body(result.body.dup)
      data               = result["LabelRequestResponse"] || {}
      encoded_zpl        = data["Base64LabelImage"]

      if (data.nil? || encoded_zpl.nil?)
        raise LabelError, (data["ErrorMessage"] || result.body.to_s)
      end

      @image      = Base64.decode64 encoded_zpl
    end
  end
end
