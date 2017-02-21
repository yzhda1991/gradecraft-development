//Initialize stacktable on all dynatables
$(".dynatable, .instructor-assignments, .badge-index-table, .paginated_dynatable").cardtable();

//Add colspan attribute to last row of each table with buttons and to headers on stacktable and instrictor-assignment tables
$(".stacktable:not(.no-button-bar) tr:last-child .st-val, .stacktable:not(.second-row-header, .no-table-header) tr:first-child .st-val, .second-row-header tr:nth-child(2) .st-val").attr("colspan","2");

//Add class to headers on stacktable and instrictor-assignment tables
$(".stacktable:not(.second-row-header, .no-table-header) tr:first-child .st-val, .second-row-header tr:nth-child(2) .st-val").addClass("table-header-row");
