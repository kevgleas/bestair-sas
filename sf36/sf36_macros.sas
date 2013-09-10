
%macro sf36_index_macro(index_array=, first_var=, last_var=, num_options=, rawindex_score=, adjindex_score=);

    num_questions = dim(&index_array);

    do i=1 to num_questions;
      if &index_array[i] < 1 or &index_array[i] > &num_options then &index_array[i] = .;
    end;

    index_num = n(of &first_var-&last_var);
    index_mean = mean(of &first_var-&last_var);

    do j=1 to num_questions;
      if &index_array[j] = . then &index_array[j] = index_mean;
    end;

    if index_num ge (&num_options * .5) then &rawindex_score = sum(of &first_var-&last_var);
    &adjindex_score = ((&rawindex_score-num_questions)/((&num_options * num_questions) - num_questions))*100;

    drop num_questions index_num index_mean i j;

%mend sf36_index_macro;
