class BaseService
  Result = Struct.new(:success, :value) do
    def success?
      success
    end

    def failure?
      !success
    end
  end

  protected

  def success(value = true)
    Result.new(true, value)
  end

  def failure(value = false)
    Result.new(false, value)
  end
end
