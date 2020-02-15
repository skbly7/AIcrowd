module MediaHelper
  def media_content_type(mediable)
    return nil if mediable.media_content_type.nil?

    media        = mediable.media_content_type.split('/')
    content_type = media[0]
    file_type    = media[1]
    return file_type if file_type == 'youtube'

    content_type = nil if ['video', 'image'].exclude?(content_type)
    return content_type
  end

  def media_asset(mediable, content_type, size)
    case content_type
    when nil
      return '-'
    when 'image'
      return render_image(mediable, size)
    when 'video'
      return render_video(mediable, size)
    when 'youtube'
      return render_youtube(mediable, size)
    end
  end

  private

  def dimensions(size)
    return "100x75" if size == :thumb
    return "800x600" if size == :large
  end

  def render_image(mediable, size)
    if s3_public_url(mediable, size).present?
      return image_tag(s3_public_url(mediable, size), size: dimensions(size), class: "media")
    else
      "-"
    end
  end

  def render_video(mediable, size)
    if s3_public_url(mediable, size).present?
      if size == :large
        return video_tag(s3_public_url(mediable, size), size: dimensions(size), controls: true, muted: true, autoplay: true, loop: true, class: "media")
      else
        return video_tag(s3_public_url(mediable, size), size: dimensions(size), autoplay: true, muted: true, loop: true, class: "media")
      end
    else
      return "-"
    end
  end

  def render_youtube(mediable, size)
    if size == :thumb && mediable.media_thumbnail.present?
      url = "https://img.youtube.com/vi/#{mediable.media_thumbnail}/0.jpg"
      return image_tag(url, size: "100x75", class: "media")
    end
    if size == :large && mediable.media_large.present?
      result = %(
        <iframe title="AIcrowd Video"
          allowfullscreen="allowfullscreen"
          mozallowfullscreen="mozallowfullscreen"
          msallowfullscreen="msallowfullscreen"
          oallowfullscreen="oallowfullscreen"
          webkitallowfullscreen="webkitallowfullscreen"
          width="800"
          height="600"
          src="//www.youtube.com/embed/#{mediable.media_large}"
          frameborder="0"
          allowfullscreen>
        </iframe>
      )
      return result.html_safe
    end
  end

  def s3_public_url(mediable, size)
    url = if size == :large
            S3Service.new(mediable.media_large).public_url
          else
            S3Service.new(mediable.media_thumbnail).public_url
          end
  end
end
