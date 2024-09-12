defmodule Whoami.TeslaCase do
  @moduledoc """
  This module defines the setup for tests testing only Tesla Api modules
  No Database

  You may define functions here to be used as helpers in
  your tests.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use Whoami.DataCase`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import Whoami.TeslaCase
    end
  end

  def assert_api_error_log(fnc, expected_content) when is_function(fnc, 0) do
    assert log = ExUnit.CaptureLog.capture_log(fnc)

    assert log =~ "API Error"
    assert log =~ expected_content
  end
end
