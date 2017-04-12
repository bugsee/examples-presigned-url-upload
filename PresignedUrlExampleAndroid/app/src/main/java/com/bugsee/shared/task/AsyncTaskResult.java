package com.bugsee.shared.task;

/** Represents result of AsyncTask execution. Contains result of specified type {@code T} or Exception instance, which occurred during AsyncTask execution.
 * Created by denis.druzhinin, Bugsee Inc, <a href="https://www.bugsee.com">https://www.bugsee.com</a>
 */
public class AsyncTaskResult<T> {
    private T mResult;
    private Throwable mError;

    public AsyncTaskResult(T result) {
        this.mResult = result;
    }

    public AsyncTaskResult(Throwable error) {
        this.mError = error;
    }

    public T getResult() {
        return mResult;
    }

    public Throwable getError() {
        return mError;
    }

    public boolean hasError() {
        return (mError != null);
    }

    public boolean hasResult() {
        return (mResult != null);
    }
}
