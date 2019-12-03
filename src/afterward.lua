






do
   if _Bridge.modules_conn then
      _Bridge.modules_conn:close()
   end

   if _Bridge.bootstrap_conn then
      _Bridge.bootstrap_conn:close()
   end
end
