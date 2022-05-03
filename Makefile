DATE	= $(shell git log -n 1 --date=short \
		| awk '/^Date:/ {print $$2}')

LINKS = \
	-V links=colorlinks \
	-V links=links-as-notes

CLASSOPTION = \
	-V classoption=oneside \
	-V classoption=idxtotoc \
	-V classoption=halfparskip \
	-V classoption=chapterprefix

GEOMETRY = \
	-V geometry=portrait \
	-V geometry=hoffset=5pt \
	-V geometry=voffset=5pt \
	-V geometry=textheight=700pt \
	-V geometry=textwidth=520pt \
	-V graphics \
	-V papersize=a4

TITLE =		Modèle de DA
SUBTITLE =	Architecture et urbanisation
		
AUTHOR = \
	-V author="L’équipe d’architecture" \
	-V equipe="Github" \
	-V date=$(DATE)

LAYOUT = \
	-V fontsize=12pt \
	-V documentclass=report \
	-V lang=fr \
	--number-sections

OUTPUT_NAME = $(TITLE) - $(SUBTITLE)

ASCII_DOCTOR_OPTS = \
	-a data-uri \
	-a allow-uri-read \
	-b docbook5 \
	--doctype=book

FILES = \
	README \
	volet-architecture-applicative \
	volet-architecture-infrastructure \
	volet-architecture-securite \
	volet-architecture-dimensionnement \
	glossaire

LATEX_OPTS = \
	--from=docbook \
	--to=latex \

PDF_OPTS = \
	--template=modele.latex \
	--toc \
	--output="$(OUTPUT_NAME).pdf"

PANDOC_OPTS = \
	-V title="$(TITLE)" \
	-V subtitle="$(SUBTITLE)" \
	$(AUTHOR) \
	$(CLASSOPTION) \
	$(GEOMETRY) \
	$(LINKS) \
	$(LAYOUT)

###############################################################################
# Help

.PHONY: help # This help message
help:
	@grep '^.PHONY: .* #' Makefile \
		| sed 's/\.PHONY: \(.*\) # \(.*\)/\1\t\2/' \
		| expand -t20 \
		| sort

###############################################################################
# Install binaries

.PHONY: prepare # Install the deb packages needed to build
prepare:
	@sudo apt -y install \
		asciidoctor \
		pandoc \
		texlive-latex-recommended \
		texlive-latex-extra \
		texlive-lang-french

###############################################################################
# Cleaning

.PHONY: clean # Delete the temporary files
clean:
	@rm -f *.html *.xml *.tex *.jpg
	
.PHONY: dist-clean # Delete the documents and temporary files
dist-clean: clean
	@rm -f *.pdf *.epub *.odt

###############################################################################
# Generate documents

.PHONY: pdf # Generate PDF document
pdf:
	cat *.adoc \
		| perl -pe 's/^#/##/' \
		| asciidoctor \
			$(ASCII_DOCTOR_OPTS) -o "$(OUTPUT_NAME).xml" -
	pandoc $(PANDOC_OPTS) $(LATEX_OPTS) $(PDF_OPTS) "$(OUTPUT_NAME).xml" 
