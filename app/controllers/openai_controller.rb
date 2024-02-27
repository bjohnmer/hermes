class OpenaiController < ApplicationController
  def service1
  end

  def handle_prompt1
    openai_service = OpenaiService.new
    @response = openai_service.generate_response(openai_params[:prompt])

    respond_to do |format|
      format.html { redirect_to openai_service1_path, notice: 'Sent' }
      format.js { render 'openai/response', layout: false }
    end
  end

  def service2
  end

  def handle_prompt2
    openai_service = GptService.new
    @response = openai_service.generate_response(openai_params[:prompt])

    respond_to do |format|
      format.html { redirect_to openai_service1_path, notice: 'Sent' }
      format.js { render 'openai/response', layout: false }
    end
  end

  private

  def openai_params
    params.require(:openai).permit(:prompt)
  end
end
