






do
   if _Bridge.modules_conn then
      _Bridge.modules_conn:pclose()
   end

   if _Bridge.bootstrap_conn then
      _Bridge.bootstrap_conn:pclose()
   end
end
