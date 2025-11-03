#!/bin/bash

# --- NEW DEBUGGING: DEFINE ABSOLUTE LOG PATH FIRST ---
PROJECT_DIR="/Users/amitmaheshwarvaranasi/Documents/projects/RAG Email Sorting"
LOG_FILE="$PROJECT_DIR/cron.log"

# --- NEW DEBUGGING: REDIRECT ALL SCRIPT OUTPUT (STDOUT & STDERR) TO THE LOG FILE ---
# This will capture every command and error, even from 'source' or 'cd'
# From this point on, all echos and errors go directly to the log.
exec >> $LOG_FILE 2>&1

# --- NEW FIX: EXPLICITLY SET HOME VARIABLE ---
# The 'source' command for .zshrc often needs $HOME to be set.
# cron's minimal environment doesn't have it.
export HOME="/Users/amitmaheshwarvaranasi"

echo "--- Starting daily report pipeline at $(date) ---"
echo "HOME variable set to: $HOME"

# --- NEW FIX: LOAD YOUR SHELL ENVIRONMENT ---
# This line loads your terminal's settings (like your PATH for Anaconda)
echo "Sourcing .zshrc..."
source /Users/amitmaheshwarvaranasi/.zshrc
echo "Sourcing complete."

# 1. DEFINE YOUR ABSOLUTE PATHS
PYTHON_EXE="/opt/anaconda3/envs/RAGProject/bin/python"
echo "Project directory set to: $PROJECT_DIR"
echo "Python executable set to: $PYTHON_EXE"

# 2. NAVIGATE TO THE PROJECT DIRECTORY
echo "Attempting to change directory to $PROJECT_DIR..."
cd $PROJECT_DIR
echo "Script is now running in directory: $(pwd)"

# 4. NEW: CLEAR OLD DATABASES FOR A FRESH DAILY RUN
echo "Clearing old databases (my_emails.db and email_vector_db/)..."
rm -f my_emails.db
rm -rf email_vector_db/
echo "Old databases cleared."

# 5. RUN THE SCRIPTS IN ORDER
# (Your filenames are correct, I am using them as you provided)
echo "Running Phase 1: Fetcher..."
$PYTHON_EXE gmail_fetcher.py

echo "Running Phase 2: Indexing..."
$PYTHON_EXE indexing.py

echo "Running Phase 3: Generation..."
$PYTHON_EXE report_generation.py

echo "Running Phase 4: Sending Email..."
$PYTHON_EXE send_report.py

echo "--- Pipeline finished at $(date) ---"
echo ""

