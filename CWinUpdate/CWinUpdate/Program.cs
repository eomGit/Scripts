using System;
using WUApiLib;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;

namespace test
{
    class Program
    {
        static class ProgressUtility
        {
            const char _block = '■';
            const string _back = "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b";
            const string _twirl = "-\\|/";

            public static void ClearCurrentConsoleLine()
            {
                int currentLineCursor = Console.CursorTop;
                Console.SetCursorPosition(0, Console.CursorTop);
                Console.Write(new string(' ', Console.WindowWidth));
                Console.SetCursorPosition(0, currentLineCursor);
            }
            public static void WriteProgressBar(int percent, bool update = false)
            {
                if (update)
                    ClearCurrentConsoleLine();
                    //Console.Write(_back);
                Console.Write("[");
                var p = (int)((percent / 10f) + .5f);
                for (var i = 0; i < 10; ++i)
                {
                    if (i >= p)
                        Console.Write(' ');
                    else
                        Console.Write(_block);
                }
                Console.Write("] {0,3:##0}%", percent);
            }
            public static void WriteProgress(int progress, bool update = false)
            {
                if (update)
                    Console.Write("\b");
                Console.Write(_twirl[progress % _twirl.Length]);
            }
        }
        private class iUpdateSearcher_onCompleted : ISearchCompletedCallback
        {
            // Implementation of IDownloadCompletedCallback interface...
            public void Invoke(ISearchJob searchJob, ISearchCompletedCallbackArgs e)
            {
                Console.Write("\b");
                Console.WriteLine("\nSearch completed.");
            }
        }

        // state [in] 
        // The caller-specific state that is returned by the AsyncState property of the ISearchJob interface.
        public class iUpdateSearcher_state
        {
            public iUpdateSearcher_state()
            {
                //Console.Write(".");
            }
        }

        private class iUpdateDownloader_onProgressChanged : IDownloadProgressChangedCallback
        {
            public static int displayLength=0;
            public iUpdateDownloader_onProgressChanged()
            {
            }

            // Implementation of IDownloadProgressChangedCallback interface...
            public void Invoke(IDownloadJob downloadJob, IDownloadProgressChangedCallbackArgs e)
            {
                decimal bDownloaded = ((e.Progress.TotalBytesDownloaded / 1024) / 1024);
                decimal bToDownloaded = ((e.Progress.TotalBytesToDownload / 1024) / 1024);
                bDownloaded = decimal.Round(bDownloaded, 2);
                bToDownloaded = decimal.Round(bToDownloaded, 2);
                /* 
                for (int i = 1; i <= displayLength; i++)
                {
                    Console.Write("\b");
                }
                //*/

                ProgressUtility.ClearCurrentConsoleLine();
                String displayString = "Downloading Update: ";
                if (downloadJob.Updates.Count > 1)
                {
                    displayString += (e.Progress.CurrentUpdateIndex + 1).ToString()
                    + "/"
                    + downloadJob.Updates.Count.ToString()
                    + " - ";
                }
                displayString += bDownloaded + "Mb" + " / "  + bToDownloaded + "Mb";
                displayLength = displayString.Length;
                Console.Write(displayString);
                //*/
           }
       }

       // onCompleted [in] 
       // An IDownloadCompletedCallback interface (C++/COM) that is called when an asynchronous download operation is complete.
       private class iUpdateDownloader_onCompleted : IDownloadCompletedCallback
       {
           /*
           private Form1 form1;

           public iUpdateDownloader_onCompleted(Form1 mainForm)
           {
               this.form1 = mainForm;
           }
           //*/
                // Implementation of IDownloadCompletedCallback interface...
            public void Invoke(IDownloadJob downloadJob, IDownloadCompletedCallbackArgs e)
            {
                Console.WriteLine("\nDownload completed.");
            }
        }

        private class iUpdateDownloader_state
        {
            public iUpdateDownloader_state()
            {
            }
        }

        public class iUpdateInstaller_onProgressChanged : IInstallationProgressChangedCallback
        {
            public static int displayLength = 0;

            // Implementation of IDownloadProgressChangedCallback interface...
            public void Invoke(IInstallationJob iInstallationJob, IInstallationProgressChangedCallbackArgs e)
            {
                ProgressUtility.ClearCurrentConsoleLine();
                String displayString = "Installing Update: ";
                if (iInstallationJob.Updates.Count>1)
                {
                    displayString += (e.Progress.CurrentUpdateIndex + 1).ToString()
                 + " / "
                 + iInstallationJob.Updates.Count
                 + " - ";
                 }
                displayString += e.Progress.CurrentUpdatePercentComplete + "% Complete";
                displayLength = displayString.Length;
                Console.Write(displayString);
            }
        }

        // onCompleted [in] 
        // An IDownloadCompletedCallback interface (C++/COM) that is called when an asynchronous download operation is complete.
        public class iUpdateInstaller_onCompleted : IInstallationCompletedCallback
        {

            // Implementation of IDownloadCompletedCallback interface...
            public void Invoke(IInstallationJob iInstallationJob, IInstallationCompletedCallbackArgs e)
            {
                Console.WriteLine("\nInstallation completed.");
            }
        }

        public class iUpdateInstaller_state
        {
            public iUpdateInstaller_state()
            {
            }
        }
        static void Main(string[] args)
        {
            IUpdateSession updateSession = new UpdateSession();
            IUpdateSearcher updateSearcher = updateSession.CreateUpdateSearcher();

            //updateSearcher.Online = false; //set to true if you want to search online
            try
            {
                Console.Write("Searching for Windows Updates  ");
                String searchString = "IsInstalled = 0 And IsHidden = 0 And Type='Software'";
                /*
                //Synchronous
                ISearchResult searchResult = updateSearcher.Search(searchString );
                //*/

                //* 
                //Asynchronous
                ISearchJob iSearchJob = updateSearcher.BeginSearch(searchString, new iUpdateSearcher_onCompleted(), new iUpdateSearcher_state());
                int counter = 0;
                ProgressUtility.WriteProgress(++counter, true);
                while (!(iSearchJob.IsCompleted))
                {
                    ProgressUtility.WriteProgress(++counter, true);
                    Thread.Sleep(200);
                }
                Console.Write("\b");
                ISearchResult searchResult = updateSearcher.EndSearch(iSearchJob);
                //*/
                ProgressUtility.WriteProgress(0, true);
                
                if (searchResult.Updates.Count > 0)
                {
                    Console.WriteLine("There are " + searchResult.Updates.Count.ToString() + " update(s) available for installation");
                    UpdateCollection NewUpdatesCollection = new UpdateCollection();

                    for (int i = 0; i < searchResult.Updates.Count; i++)
                    {
                        IUpdate iUpdate = searchResult.Updates[i];
                        Console.WriteLine((i+1).ToString() + ": " + iUpdate.Title);
                        if (!(iUpdate.InstallationBehavior.CanRequestUserInput))
                        {
                            if (!(iUpdate.EulaAccepted))
                            {
                                Console.WriteLine("+---- Acepting EULA.");
                                iUpdate.AcceptEula();
                            }
                            if (iUpdate.IsDownloaded)
                            {
                                Console.WriteLine("+---- Update already downloaded.");
                            }
                            NewUpdatesCollection.Add(iUpdate);
                        }
                        else
                        {
                            Console.WriteLine("+---- Skipping since user input is required.");
                        }
                    }
                    IUpdateDownloader iUpdateDownloader = updateSession.CreateUpdateDownloader();

                    iUpdateDownloader.Updates = NewUpdatesCollection;
                    iUpdateDownloader.Priority = DownloadPriority.dpHigh;

                    IDownloadJob iDownloadJob = iUpdateDownloader.BeginDownload(new iUpdateDownloader_onProgressChanged(), new iUpdateDownloader_onCompleted(), new iUpdateDownloader_state());

                    while (!(iDownloadJob.IsCompleted))
                    {
                        Thread.Sleep(1000);
                    }

                    IDownloadResult iDownloadResult = iUpdateDownloader.EndDownload(iDownloadJob);
                    if (iDownloadResult.ResultCode == OperationResultCode.orcSucceeded)
                    {
                        Console.WriteLine("Download successful.");
                    }
                    else
                    {
                        //TODO: What if not able to download
                    }
                    IUpdateInstaller iUpdateInstaller = updateSession.CreateUpdateInstaller() as IUpdateInstaller;
                    iUpdateInstaller.Updates = NewUpdatesCollection;

                    IInstallationJob iInstallationJob  =  iUpdateInstaller.BeginInstall(new iUpdateInstaller_onProgressChanged(), new iUpdateInstaller_onCompleted(), new iUpdateInstaller_state());

                    while (!(iInstallationJob.IsCompleted))
                    {
                        Thread.Sleep(1000);
                    }

                    IInstallationResult iInstallationResult = iUpdateInstaller.EndInstall(iInstallationJob);

                    if (iInstallationResult.ResultCode == OperationResultCode.orcSucceeded)
                    {
                        Console.WriteLine("Installation Successul.");
                    }
                    else
                    {
                        Console.WriteLine("One or more updates failed: " + iInstallationResult.ResultCode + ".");
                        for(int i=0; i < NewUpdatesCollection.Count; i++)
                        {
                            if (iInstallationResult.GetUpdateResult(i).ResultCode != OperationResultCode.orcSucceeded)
                            {
                                Console.WriteLine(" =====> " + NewUpdatesCollection[i].Title + " failed with code " + iInstallationResult.GetUpdateResult(i).HResult);
                            }
                        }
                    }
                    if (iInstallationResult.RebootRequired)
                    {
                        Console.WriteLine("***REBOOT REQUIRED***");
                    }
                }
                else
                {
                    Console.WriteLine("There are no updates available.");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message, "Error");
            }
        }
    }
}
