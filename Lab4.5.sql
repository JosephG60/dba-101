SELECT ec.session_id, tst.is_user_transaction, st.text 
   FROM sys.dm_tran_session_transactions tst 
      INNER JOIN sys.dm_exec_connections ec ON tst.session_id = ec.session_id
      CROSS APPLY sys.dm_exec_sql_text(ec.most_recent_sql_handle) st