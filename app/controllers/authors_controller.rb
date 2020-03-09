class AuthorsController < ApplicationController

  helper_method :posts, :author

  def update
    if author.update(author_params)
      redirect_to root_path, notice: 'author updated'
    else
      render :edit
    end
  end

  private

  def author
    @author ||= if params[:action] == "show"
                   author.find_by_username!(params[:id])
                 else
                   current_author
                 end
  end

  def author_params
    params.require(:author).permit(:editor, :twitter_handle, :slack_name)
  end

  def posts
    @posts ||= author.posts.published_and_ordered.includes(:channel)
  end
end
