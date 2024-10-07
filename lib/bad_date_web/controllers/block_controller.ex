defmodule BadDateWeb.BlockController do
  use BadDateWeb, :controller
  alias BadDate.Accounts
  alias BadDate.Accounts.Block

  # Index action to list blocked users
  def index(conn, _params) do
    user = conn.assigns[:current_user]

    # Get the list of blocked users
    blocked_users = Accounts.list_blocked_users(user.id)
    changeset = Accounts.change_block(%Block{})
    
    # Pass both blocked_users and changeset to the template
    render(conn, "blocked.html", blocked_users: blocked_users, changeset: changeset)
  end
    # Action to handle the /blocked route, rendering the blocked list page
  def blocked(conn, _params) do
    user = conn.assigns[:current_user]

    # Fetch the blocked users for this user
    blocked_users = Accounts.list_blocked_users(user.id)

    # Render the blocked.html with the list of blocked users
    changeset = Accounts.change_block(%Block{})
    render(conn, "blocked.html", blocked_users: blocked_users, changeset: changeset)
  end

  # Action to block a user
  def block(conn, %{"block" => %{"blocked_user_email" => blocked_email}}) do
    blocker_id = conn.assigns[:current_user].id
    blocked_user = Accounts.get_user_by_email(blocked_email)
  
   if blocked_user do
    case Accounts.block_user(blocker_id, blocked_user.id) do
      {:ok, _block} ->
        conn
        |> put_flash(:info, "User blocked successfully.")
        |> redirect(to: Routes.block_path(conn, :index))  # Redirect to the list of blocked users
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Could not block the user.")
        |> redirect(to: Routes.block_path(conn, :index))  
    end
  else
    conn
    |> put_flash(:error, "User not found.")
    |> redirect(to: Routes.block_path(conn, :index))
  end
end  

  # Action to unblock a user
  def unblock(conn, %{"blocked_id" => blocked_id}) do
    blocker_id = conn.assigns[:current_user].id

    case Accounts.unblock_user(blocker_id, blocked_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "User unblocked successfully.")
        |> redirect(to: Routes.block_path(conn, :index))  # Redirect to the list of blocked users
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Could not unblock the user.")
        |> redirect(to: Routes.block_path(conn, :index))  
    end
  end
end

