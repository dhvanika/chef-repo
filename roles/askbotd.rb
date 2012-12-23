name "askbotd"
description "AskBot Development"
run_list "recipe[cksimple::users]","recipe[cksimple::postgres]","recipe[cksimple::askbot]","recipe[cksimple::nfs]" 

