*macro to check endpoint completion;
*using passed array of variables to check, returns 1 for fully complete, 0 for partially complete, . for fully missing to a declared variable;
%macro endpointcheck_macro(endpoint_array=, result_var=);

    endpoint_errors = 0;
    &result_var = 1;

    do endpoint_index = 1 to dim(&endpoint_array);
      if &endpoint_array[endpoint_index] < 0 or &endpoint_array[endpoint_index] = .
        then do;
          &result_var = 0;
          endpoint_errors = endpoint_errors + 1;
        end;
    end;

    if endpoint_errors = dim(&endpoint_array) then &result_var = .;

    drop endpoint_index endpoint_errors;

%mend endpointcheck_macro;
