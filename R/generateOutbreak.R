#' Generate random data of an outbreak
#' 
#' A function to create a sample dataset of an outbreak
#' @param n Number of persons
#' @param percentageCases Number between 0 and 1 representing the percentage of cases
#' @param pathogen Quoted character value of the pathogen causing the outbreak. Possible values are: "Salmonella", "Ebola", "Norovirus", "Measles", "Influenza"
#' @param tpye Quoted character value of type of outbreak. Possible values are: "pointsource", "propageted", "continuing"
#' @param startdate Quoted character value of the first possible date of onset of disease with the format "YYYY-MM-DD". For example: "2013-09-23"
#' @param startdate Quoted character value of the last possible date of onset of disease with the format "YYYY-MM-DD". For example: "2013-09-23"
#' @param dataquality Quoted character value of the output quality of the dataset. Possible values are: "good", "standard", "messy". "standard" introduces Na Values, "messy" introduces NA and other random values.
#' @return A dataset of a random outbreak 
#' @keywords epidemiology
#' @export


generateOutbreak <- function(n=100,
                             percentageCases=0.5,
                             pathogen="Salmonella",
                             type="pointsource", # other are "propageted", "continuing"
                             startdate="2013-09-23",
                             enddate="2013-10-04",
                             dataquality="standard",
                             probabilityOfTrueExposue=0.2,
                             numberExposures=5){
  
  # Initialize data.frame
  df <- data.frame(number=1:n)
  
  # Dates to dates
  startdate <- as.Date(startdate)
  enddate <- as.Date(enddate)
  
  
  #---------------------------- Data to generate names and exposures -------------------------------------
  cookbook <- c("Ewout Fanoy-The Dutch snack wall", "Nadine Zeitlmann-Obazda", "Sergejs Nikišins-Pelekie zirni ar spekiti", "Tommi Kärki-Pasta alla carbonara",
                "Gayle Dolan-Pan Haggerty", "Mathieu Bangert-Tortilla", "Jakob Schumacher-Käsespätzle", "Anika Schielke-Braunschweiger", "Sandra van Dam-Boerenkool",
                "Sophie Newitt-Balti", "Alison Waldram-Scouse", "Viktor Dahl-Köttbullar", "Konstantinos Koutendakis-Stuffed Vegetables", "Coralie Giese-Irish seafood chowder",
                "Laura Nic Lochlainn-Irish brown soda bread", "Heidi Lange-Fårikål", "Ieva Kantsone-Sklandrausis", "Alex Sánchez-Vivar-Scottish Haggis",
                "Christiane Wagner-Wiening-Schwäbische Maultaschen", "Zuzana Klochanova-Špenátovo-bryndzové halušky", "Chrysovalantis Silvestros-Moussaka",
                "Yung-Ching Lin-Wiener Schnitzel", "Zoltan Kis-Marhapörkölt", "Claudia Lucarelli-Tiramisu", "Laure Fonteneau-Crêpes", "Tara Shivaji-Arroz doce",
                "Orla Condell-Risalamande", "Triin Pärn-White chocolate blueberry cheesecake", "Ani Ioana Cotar-Cozonac cu nuca", "Jane Hecht-Almond cookies","Thomas Waite-Pice bach ar y maen",
                "Anne Lallemand-croissants aux pignons","Maja George-Schneller Bienenstich","Gerit Korr-Saxon egg custard cake","Kirsty Hewitt-Lemon drizzle cake","Manuela Harries-Lüttje Lage",
                "Anne Carrol-Irish Coffee","Rachel Freeman-Espresso martini","Didrik Vestrheim","Margot Einöder-Moreno","Annika Wendland")
  
  food <- gsub(" ", "", tolower(na.omit(sapply(strsplit(cookbook, split="-"),function(x) x[2]))))
  names <- na.omit(sapply(strsplit(cookbook, split="-"),function(x) x[1]))
  firstnames <- sapply(strsplit(names, split=" "),function(x) x[1])
  lastnames <- sapply(strsplit(names, split=" "),function(x) x[2])
  
  if (dataquality!="messy") {
    iconv(food, "UTF-8", "ASCII", sub="")
  }
  
  
  # -------------------------- Generate random ids -----------------------------------------------
  id <- sample(c(toupper(letters), tolower(letters), 0:9), size=8*n, replace=TRUE)
  id <- paste0(id, collapse="")
  df$id <- substring(id, seq(1,nchar(id),8), seq(8,nchar(id),8))
  
  #-------------------------------------- Ill --------------------------------------------------
  df$ill <- sample(c(TRUE, FALSE), size=n, prob=c(percentageCases, 1-percentageCases), replace=TRUE)
  
  #-------------------------------------- Time --------------------------------------------------
  if(pathogen=="Salmonella") {incubationtime=2}
  if(pathogen=="Norovirus") {incubationtime=1}
  if(pathogen=="Measles") {incubationtime=12}
  if(pathogen=="Influenza") {incubationtime=2}
  if(pathogen=="Ebola") {incubationtime=9}
  
  if(type=="pointsource") {
    dates <- as.numeric(startdate)+rpois(n=n, lambda=incubationtime)
    dates <- dates[dates<as.numeric(enddate)]
    df$onset <- as.Date(ifelse(df$ill, sample(dates, replace=TRUE), NA),  origin="1970-01-01")
  }
  
  if(type=="continuing") {
    dates_beginning <- as.numeric(stardate)+rpois(n=n/2, lambda=incubationtime)
    dates_beginning <- dates_beginning[dates<as.numeric(stardate+incubationtime)]
    dates_plateau <- round(runif(n=n, min=stardate+incubationtime, max=enddate))
    dates <- c(dates_beginning, dates_plateau)
    df$onset <- as.Date(ifelse(df$ill, sample(dates, replace=TRUE), NA), origin="1970-01-01")
  }
  
  if(type=="propageted") {
    peakdates <- seq(startdate+incubationtime,enddate, by=incubationtime)
    dates <- sapply(peakdates, function(x) rnorm(n=n/length(peakdates), x, sd=incubationtime/3))
    dates <- as.Date(dates, origin="1970-01-01")
    dates <- dates[dates>as.numeric(startdate)&dates<as.numeric(enddate)]
    df$onset <- as.Date(ifelse(df$ill, sample(dates, replace=TRUE), NA), origin="1970-01-01")
  }
  
  #-------------------------------------- Place --------------------------------------------------
  p <- c("AT111","AT112","AT113","AT121","AT122","AT123","AT124","AT125","AT126","AT127","AT130","AT211","AT212","AT213","AT221","AT222","AT223","AT224","AT225","AT226","AT311","AT312","AT313","AT314","AT315","AT321","AT322","AT323","AT331","AT332","AT333","AT334","AT335","AT341","AT342","BE100","BE211","BE212","BE213","BE221","BE222","BE223","BE231","BE232","BE233","BE234","BE235","BE236","BE241","BE242","BE251","BE252","BE253","BE254","BE255","BE256","BE257","BE258","BE310","BE321","BE322","BE323","BE324","BE325","BE326","BE327","BE331","BE332","BE334","BE335","BE336","BE341","BE342","BE343","BE344","BE345","BE351","BE352","BE353","BG311","BG312","BG313","BG314","BG315","BG321","BG322","BG323","BG324","BG325","BG331","BG332","BG333","BG334","BG341","BG342","BG343","BG344","BG411","BG412","BG413","BG414","BG415","BG421","BG422","BG423","BG424","BG425","CY000","CZ010","CZ020","CZ031","CZ032","CZ041","CZ042","CZ051","CZ052","CZ053","CZ063","CZ064","CZ071","CZ072","CZ080")
  p2 <- c("DE111","DE112","DE113","DE114","DE115","DE116","DE117","DE118","DE119","DE11A","DE11B","DE11C","DE11D","DE121","DE122","DE123","DE124","DE125","DE126","DE127","DE128","DE129","DE12A","DE12B","DE12C","DE131","DE132","DE133","DE134","DE135","DE136","DE137","DE138","DE139","DE13A","DE141","DE142","DE143","DE144","DE145","DE146","DE147","DE148","DE149","DE211","DE212","DE213","DE214","DE215","DE216","DE217","DE218","DE219","DE21A","DE21B","DE21C","DE21D","DE21E","DE21F","DE21G","DE21H","DE21I","DE21J","DE21K","DE21L","DE21M","DE21N","DE221","DE222","DE223","DE224","DE225","DE226","DE227","DE228","DE229","DE22A","DE22B","DE22C","DE231","DE232","DE233","DE234","DE235","DE236","DE237","DE238","DE239","DE23A","DE241","DE242","DE243","DE244","DE245","DE246","DE247","DE248","DE249","DE24A","DE24B","DE24C","DE24D","DE251","DE252","DE253","DE254","DE255","DE256","DE257","DE258","DE259","DE25A","DE25B","DE25C","DE261","DE262","DE263","DE264","DE265","DE266","DE267","DE268","DE269","DE26A","DE26B","DE26C","DE271","DE272","DE273","DE274","DE275","DE276","DE277","DE278","DE279","DE27A","DE27B","DE27C","DE27D","DE27E","DE300","DE401","DE402","DE403","DE404","DE405","DE406","DE407","DE408","DE409","DE40A","DE40B","DE40C","DE40D","DE40E","DE40F","DE40G","DE40H","DE40I","DE501","DE502","DE600","DE711","DE712","DE713","DE714","DE715","DE716","DE717","DE718","DE719","DE71A","DE71B","DE71C","DE71D","DE71E","DE721","DE722","DE723","DE724","DE725","DE731","DE732","DE733","DE734","DE735","DE736","DE737","DE801","DE802","DE803","DE804","DE805","DE806","DE807","DE808","DE809","DE80A","DE80B","DE80C","DE80D","DE80E","DE80F","DE80G","DE80H","DE80I","DE911","DE912","DE913","DE914","DE915","DE916","DE917","DE918","DE919","DE91A","DE91B","DE922","DE923","DE925","DE926","DE927","DE928","DE929","DE931","DE932","DE933","DE934","DE935","DE936","DE937","DE938","DE939","DE93A","DE93B","DE941","DE942","DE943","DE944","DE945","DE946","DE947","DE948","DE949","DE94A","DE94B","DE94C","DE94D","DE94E","DE94F","DE94G","DE94H","DEA11","DEA12","DEA13","DEA14","DEA15","DEA16","DEA17","DEA18","DEA19","DEA1A","DEA1B","DEA1C","DEA1D","DEA1E","DEA1F","DEA22","DEA23","DEA24","DEA26","DEA27","DEA28","DEA29","DEA2A","DEA2B","DEA2C","DEA2D","DEA31","DEA32","DEA33","DEA34","DEA35","DEA36","DEA37","DEA38","DEA41","DEA42","DEA43","DEA44","DEA45","DEA46","DEA47","DEA51","DEA52","DEA53","DEA54","DEA55","DEA56","DEA57","DEA58","DEA59","DEA5A","DEA5B","DEA5C","DEB11","DEB12","DEB13","DEB14","DEB15","DEB16","DEB17","DEB18","DEB19","DEB1A","DEB1B","DEB21","DEB22","DEB23","DEB24","DEB25","DEB31","DEB32","DEB33","DEB34","DEB35","DEB36","DEB37","DEB38","DEB39","DEB3A","DEB3B","DEB3C","DEB3D","DEB3E","DEB3F","DEB3G","DEB3H","DEB3I","DEB3J","DEB3K","DEC01","DEC02","DEC03","DEC04","DEC05","DEC06","DED21","DED2C","DED2D","DED2E","DED2F","DED41","DED42","DED43","DED44","DED45","DED51","DED52","DED53","DEE01","DEE02","DEE03","DEE04","DEE05","DEE06","DEE07","DEE08","DEE09","DEE0A","DEE0B","DEE0C","DEE0D","DEE0E","DEF01","DEF02","DEF03","DEF04","DEF05","DEF06","DEF07","DEF08","DEF09","DEF0A","DEF0B","DEF0C","DEF0D","DEF0E","DEF0F","DEG01","DEG02","DEG03","DEG04","DEG05","DEG06","DEG07","DEG09","DEG0A","DEG0B","DEG0C","DEG0D","DEG0E","DEG0F","DEG0G","DEG0H","DEG0I","DEG0J","DEG0K","DEG0L","DEG0M","DEG0N","DEG0P","DK011","DK012","DK013","DK014","DK021","DK022","DK031","DK032","DK041","DK042","DK050")
  p3 <- c("EE001","EE004","EE006","EE007","EE008","EL111","EL112","EL113","EL114","EL115","EL121","EL122","EL123","EL124","EL125","EL126","EL127","EL131","EL132","EL133","EL134","EL141","EL142","EL143","EL144","EL211","EL212","EL213","EL214","EL221","EL222","EL223","EL224","EL231","EL232","EL233","EL241","EL242","EL243","EL244","EL245","EL251","EL252","EL253","EL254","EL255","EL300","EL411","EL412","EL413","EL421","EL422","EL431","EL432","EL433","EL434","ES111","ES112","ES113","ES114","ES120","ES130","ES211","ES212","ES213","ES220","ES230","ES241","ES242","ES243","ES300","ES411","ES412","ES413","ES414","ES415","ES416","ES417","ES418","ES419","ES421","ES422","ES423","ES424","ES425","ES431","ES432","ES511","ES512","ES513","ES514","ES521","ES522","ES523","ES531","ES532","ES533","ES611","ES612","ES613","ES614","ES615","ES616","ES617","ES618","ES620","ES630","ES640","ES703","ES704","ES705","ES706","ES707","ES708","ES709","FI193","FI194","FI195","FI196","FI197","FI1B1","FI1C1","FI1C2","FI1C3","FI1C4","FI1C5","FI1D1","FI1D2","FI1D3","FI1D4","FI1D5","FI1D6","FI1D7","FI200","FR101","FR102","FR103","FR104","FR105","FR106","FR107","FR108","FR211","FR212","FR213","FR214","FR221","FR222","FR223","FR231","FR232","FR241","FR242","FR243","FR244","FR245","FR246","FR251","FR252","FR253","FR261","FR262","FR263","FR264","FR301","FR302","FR411","FR412","FR413","FR414","FR421","FR422","FR431","FR432","FR433","FR434","FR511","FR512","FR513","FR514","FR515","FR521","FR522","FR523","FR524","FR531","FR532","FR533","FR534","FR611","FR612","FR613","FR614","FR615","FR621","FR622","FR623","FR624","FR625","FR626","FR627","FR628","FR631","FR632","FR633","FR711","FR712","FR713","FR714","FR715","FR716","FR717","FR718","FR721","FR722","FR723","FR724","FR811","FR812","FR813","FR814","FR815","FR821","FR822","FR823","FR824","FR825","FR826","FR831","FR832","FR910","FR920","FR930","FR940","HR031","HR032","HR033","HR034","HR035","HR036","HR037","HR041","HR042","HR043","HR044","HR045","HR046","HR047","HR048","HR049","HR04A","HR04B","HR04C","HR04D","HR04E","HU101","HU102","HU211","HU212","HU213","HU221","HU222","HU223","HU231","HU232","HU233","HU311","HU312","HU313","HU321","HU322","HU323","HU331","HU332","HU333","IE011","IE012","IE013","IE021","IE022","IE023","IE024","IE025","ITC11","ITC12","ITC13","ITC14","ITC15","ITC16","ITC17","ITC18","ITC20","ITC31","ITC32","ITC33","ITC34","ITC41","ITC42","ITC43","ITC44","ITC46","ITC47","ITC48","ITC49","ITC4A","ITC4B","ITC4C","ITC4D","ITF11","ITF12","ITF13","ITF14","ITF21","ITF22","ITF31","ITF32","ITF33","ITF34","ITF35","ITF43","ITF44","ITF45","ITF46","ITF47","ITF48","ITF51","ITF52","ITF61","ITF62","ITF63","ITF64","ITF65","ITG11","ITG12","ITG13","ITG14","ITG15","ITG16","ITG17","ITG18","ITG19","ITG25","ITG26","ITG27","ITG28","ITG29","ITG2A","ITG2B","ITG2C","ITH10","ITH20","ITH31","ITH32","ITH33","ITH34","ITH35","ITH36","ITH37","ITH41","ITH42","ITH43","ITH44","ITH51","ITH52","ITH53","ITH54","ITH55","ITH56","ITH57","ITH58","ITH59","ITI11","ITI12","ITI13","ITI14","ITI15","ITI16","ITI17","ITI18","ITI19","ITI1A","ITI21","ITI22","ITI31","ITI32","ITI33","ITI34","ITI35","ITI41","ITI42","ITI43","ITI44","ITI45","LT001","LT002","LT003","LT004","LT005","LT006","LT007","LT008","LT009","LT00A","LU000","LV003","LV005","LV006","LV007","LV008","LV009")
  p4 <- c("MK001","MK002","MK003","MK004","MK005","MK006","MK007","MK008","MT001","MT002","NL111","NL112","NL113","NL121","NL122","NL123","NL131","NL132","NL133","NL211","NL212","NL213","NL221","NL224","NL225","NL226","NL230","NL310","NL321","NL322","NL323","NL324","NL325","NL326","NL327","NL332","NL333","NL337","NL338","NL339","NL33A","NL341","NL342","NL411","NL412","NL413","NL414","NL421","NL422","NL423","NO011","NO012","NO021","NO022","NO031","NO032","NO033","NO034","NO041","NO042","NO043","NO051","NO052","NO053","NO061","NO062","NO071","NO072","NO073","PL113","PL114","PL115","PL116","PL117","PL121","PL122","PL127","PL128","PL129","PL12A","PL213","PL214","PL215","PL216","PL217","PL224","PL225","PL227","PL228","PL229","PL22A","PL22B","PL22C","PL311","PL312","PL314","PL315","PL323","PL324","PL325","PL326","PL331","PL332","PL343","PL344","PL345","PL411","PL414","PL415","PL416","PL417","PL418","PL422","PL423","PL424","PL425","PL431","PL432","PL514","PL515","PL516","PL517","PL518","PL521","PL522","PL613","PL614","PL615","PL621","PL622","PL623","PL631","PL633","PL634","PL635","PT111","PT112","PT113","PT114","PT115","PT116","PT117","PT118","PT150","PT161","PT162","PT163","PT164","PT165","PT166","PT167","PT168","PT169","PT16A","PT16B","PT16C","PT171","PT172","PT181","PT182","PT183","PT184","PT185","PT200","PT300","RO111","RO112","RO113","RO114","RO115","RO116","RO121","RO122","RO123","RO124","RO125","RO126","RO211","RO212","RO213","RO214","RO215","RO216","RO221","RO222","RO223","RO224","RO225","RO226","RO311","RO312","RO313","RO314","RO315","RO316","RO317","RO321","RO322","RO411","RO412","RO413","RO414","RO415","RO421","RO422","RO423","RO424","SE110","SE121","SE122","SE123","SE124","SE125","SE211","SE212","SE213","SE214","SE221","SE224","SE231","SE232","SE311","SE312","SE313","SE321","SE322","SE331","SE332","SI011","SI012","SI013","SI014","SI015","SI016","SI017","SI018","SI021","SI022","SI023","SI024","SK010","SK021","SK022","SK023","SK031","SK032","SK041","SK042","TR100","TR211","TR212","TR213","TR221","TR222","TR310","TR321","TR322","TR323","TR331","TR332","TR333","TR334","TR411","TR412","TR413","TR421","TR422","TR423","TR424","TR425","TR510","TR521","TR522","TR611","TR612","TR613","TR621","TR622","TR631","TR632","TR633","TR711","TR712","TR713","TR714","TR715","TR721","TR722","TR723","TR811","TR812","TR813","TR821","TR822","TR823","TR831","TR832","TR833","TR834","TR901","TR902","TR903","TR904","TR905","TR906","TRA11","TRA12","TRA13","TRA21","TRA22","TRA23","TRA24","TRB11","TRB12","TRB13","TRB14","TRB21","TRB22","TRB23","TRB24","TRC11","TRC12","TRC13","TRC21","TRC22","TRC31","TRC32","TRC33","TRC34","UKC11","UKC12","UKC13","UKC14","UKC21","UKC22","UKC23","UKD11","UKD12","UKD31","UKD32","UKD41","UKD42","UKD43","UKD61","UKD62","UKD63","UKD71","UKD72","UKD73","UKD74","UKE11","UKE12","UKE13","UKE21","UKE22","UKE31","UKE32","UKE41","UKE42","UKE44","UKE45","UKF11","UKF12","UKF13","UKF14","UKF15","UKF16","UKF21","UKF22","UKF24","UKF25","UKF30","UKG11","UKG12","UKG13","UKG21","UKG22","UKG23","UKG24","UKG31","UKG32","UKG33","UKG36","UKG37","UKG38","UKG39","UKH11","UKH12","UKH13","UKH14","UKH21","UKH23","UKH24","UKH25","UKH31","UKH32","UKH33","UKI11","UKI12","UKI21","UKI22","UKI23","UKJ11","UKJ12","UKJ13","UKJ14","UKJ21","UKJ22","UKJ23","UKJ24","UKJ31","UKJ32","UKJ33","UKJ34","UKJ41","UKJ42","UKK11","UKK12","UKK13","UKK14","UKK15","UKK21","UKK22","UKK23","UKK30","UKK41","UKK42","UKK43","UKL11","UKL12","UKL13","UKL14","UKL15","UKL16","UKL17","UKL18","UKL21","UKL22","UKL23","UKL24","UKM21","UKM22","UKM23","UKM24","UKM25","UKM26","UKM27","UKM28","UKM31","UKM32","UKM33","UKM34","UKM35","UKM36","UKM37","UKM38","UKM50","UKM61","UKM62","UKM63","UKM64","UKM65","UKM66","UKN01","UKN02","UKN03","UKN04","UKN05")
  nutscodes <- factor(c(p, p2, p3, p4))
  df$place <- nutscodes[round(rnorm(n=n, mean=as.numeric(sample(1:length(nutscodes), size=1, replace=TRUE)), sd=5))]
  
  #-------------------------------------- Person --------------------------------------------------
  df$names <- paste(sample(firstnames,n, replace=TRUE), sample(lastnames,n, replace=TRUE))
  
  #-------------------------------------- Age --------------------------------------------------
  df$age <- sample(1:90, size=n, replace=TRUE)
  
  #-------------------------------------- Symptoms --------------------------------------------------
  if(pathogen=="Salmonella") {
    df$stomachpain <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.9, 0.1), replace=T), FALSE)
    df$diarrhea <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.8, 0.2), replace=T), FALSE)
    df$vomiting <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.5, 0.5), replace=T), FALSE)
    df$fever <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.3, 0.7), replace=T), FALSE)
    df$gastrointestinalbleeding <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.1, 0.9), replace=T), FALSE)
  }
  
  if(pathogen=="Norovirus") {
    df$stomachpain <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.9, 0.1), replace=T), FALSE)
    df$diarrhea <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.8, 0.2), replace=T), FALSE)
    df$vomiting <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.5, 0.5), replace=T), FALSE)
    df$fever <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.2, 0.8), replace=T), FALSE)
  }
  
  if(pathogen=="Measles") {
    df$rash <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.9, 0.1), replace=T), FALSE)
    df$fever <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.8, 0.2), replace=T), FALSE)
    df$sorethroat <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.5, 0.5), replace=T), FALSE)
    df$conjunctivitis <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.2, 0.8), replace=T), FALSE)
    df$complications <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.1, 0.9), replace=T), FALSE)
  }
  
  if(pathogen=="Influenza") {
    df$fever <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.9, 0.1), replace=T), FALSE)
    df$cough <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.8, 0.2), replace=T), FALSE)
    df$sorethroat <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.5, 0.5), replace=T), FALSE)
    df$runnynose <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.2, 0.8), replace=T), FALSE)
    df$musclepain <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.1, 0.9), replace=T), FALSE)
  }
  
  if(pathogen=="Ebola") {
    df$fever <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.9, 0.1), replace=T), FALSE)
    df$headacke <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.8, 0.2), replace=T), FALSE)
    df$weakness <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.5, 0.5), replace=T), FALSE)
    df$diarrhea <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.6, 0.4), replace=T), FALSE)
    df$hemorrhage  <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.5, 0.5), replace=T), FALSE)
    df$death  <- ifelse(df$ill, sample(c(TRUE, FALSE), prob=c(0.4, 0.6), replace=T), FALSE)
  }
  
  #-------------------------------------- Exposures --------------------------------------------------
  if(pathogen=="Salmonella"|pathogen=="Norovirus") {
    
    for(i in 1:numberExposures) {
      l <- length(names(df))
      causativeExposure <- sample(c(TRUE, FALSE), size=1, prob=c(probabilityOfTrueExposue, 1-probabilityOfTrueExposue))
      
      if(causativeExposure) {df$exposure <- ifelse(df$ill, 
                                                   sample(c(TRUE, FALSE), size=nrow(df), prob=c(0.8, 0.2), replace=T),
                                                   sample(c(TRUE, FALSE), size=nrow(df), prob=c(0.2, 0.8), replace=T))}
      if(!causativeExposure) {df$exposure <- sample(c(TRUE, FALSE), size=nrow(df), prob=c(0.5, 0.5), replace=T)}
      
      names(df)[l+1] <- sample(food, size=length(names(df)[grepl("exposure", names(df))]), replace=T)
    }
  }  
  
  #-------------------------------------- Vaccination --------------------------------------------------
  if(pathogen=="Influenza"|pathogen=="Measles") {
    df$vaccination <- ifelse(df$ill, 
                             sample(c(TRUE, FALSE), size=1, prob=c(0.1, 0.9), replace=T), 
                             sample(c(TRUE, FALSE), size=1, prob=c(0.9, 0.1), replace=T))
  }
  
  if(pathogen=="Ebola") {
    df$vaccination <- ifelse(df$ill, 
                             sample(c(TRUE, FALSE), size=1, prob=c(0.1, 0.9), replace=T), 
                             sample(c(TRUE, FALSE), size=1, prob=c(0.2, 0.8), replace=T))
  }
  
  
  #-------------------------------------- Risk factors --------------------------------------------------
  if(pathogen=="Ebola") {
    df$unsafeburial <- ifelse(df$ill, 
                              sample(c(TRUE, FALSE), size=1, prob=c(0.3, 0.7), replace=T), 
                              sample(c(TRUE, FALSE), size=1, prob=c(0.1, 0.9), replace=T))
    
    df$healthcareworker <- ifelse(df$ill, 
                                  sample(c(TRUE, FALSE), size=1, prob=c(0.3, 0.7), replace=T), 
                                  sample(c(TRUE, FALSE), size=1, prob=c(0.1, 0.9), replace=T))
    
    df$contactperson <- ifelse(df$ill, 
                               sample(c(TRUE, FALSE), size=1, prob=c(0.6, 0.4), replace=T), 
                               sample(c(TRUE, FALSE), size=1, prob=c(0.1, 0.9), replace=T))
  }
  
  
  #-------------------------------------- Simulate data quality --------------------------------------------------
  randomWords <- c("The primary aim of EPIET is to strengthen capacity of the workforce in the EU through providing state-of-the-art training in field epidemiology enabling its fellows to apply epidemiological methods to a wide range of public health problems in Europe and elsewhere.The main emphasis of the programme is on learning through delivery of public health service. As fully-fledged professionals, fellows deliver products that contribute to prevention of disease, death and disability and that protect the EU against communicable disease threats.")
  randomWords <- unlist(strsplit(randomWords, split=" "))
  
  if(dataquality=="messy") {
    randomNA <- function(x) {
      randomrows <- round(runif(nrow(df)*0.1,3,nrow(df)))
      x[randomrows] <- NA
      randomrows <- round(runif(nrow(df)*0.02,3,nrow(df)))
      x[randomrows] <- sample(c(rep(" ", 30), rep("-",30), rep("unkown",5), randomWords), size=length(randomrows), replace=T)
      x
    }
    df <- data.frame(apply(df[3:dim(df)[2]], 2, randomNA))
  }
  
  if(dataquality=="standard") {
    df[-1] <- lapply(df[-1], function(x) { x[sample(c(1:n), floor(n/10))] <- NA ; x })
  }
  
  
  df
  
}
